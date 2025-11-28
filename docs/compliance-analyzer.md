# Compliance Analyzer

The Compliance Analyzer checks that pages follow BetterPage architecture rules.

## Running the Analyzer

### Analyze All Pages

```bash
rake better_page:compliance:analyze
```

### Verbose Mode

```bash
VERBOSE=true rake better_page:compliance:analyze
```

## Architecture Rules

### 1. No Database Queries

Pages must not execute database queries. Data should be passed via constructor.

**Forbidden patterns:**

```ruby
# WRONG
def header
  { title: "#{User.count} Users" }  # Database query
end

# WRONG
def table
  { items: User.where(active: true) }  # Database query
end
```

**Correct:**

```ruby
def initialize(users, stats)
  @users = users
  @stats = stats
end

def header
  { title: "#{@stats[:count]} Users" }  # Data from constructor
end
```

### 2. No Business Logic

Pages must not contain business calculations or processing.

**Forbidden patterns:**

```ruby
def calculate_total  # Business calculation
def process_data     # Business processing
def validate_user    # Validation logic
def save_record      # Persistence
```

### 3. No Service Layer Access

Pages must not instantiate or use service objects.

**Forbidden:**

```ruby
def header
  result = UserService.new.get_stats  # Service access
  { title: result[:title] }
end
```

### 4. No External Dependencies

Pages must not use external HTTP clients or services.

**Forbidden patterns:**

```ruby
Net::HTTP
HTTParty
Faraday
Redis
```

### 5. Required Component Methods

Each page type must implement required component methods:

| Page Type | Required Methods |
|-----------|-----------------|
| IndexPage | `header`, `table` |
| ShowPage | `header` |
| FormPage (new/edit) | `header`, `panels` |
| CustomPage | `content` |

### 6. Hash-Only Structures

Pages must use plain Hash objects, not OpenStruct or Struct.

**Forbidden:**

```ruby
OpenStruct.new(title: "Users")
Struct.new(:title)
```

**Correct:**

```ruby
{ title: "Users" }
```

## Report Output

### Summary

```
SUMMARY
=======
Total pages analyzed: 25
[OK] Fully compliant: 20 (80.0%)
[WARN] With warnings: 3 (12.0%)
[ERROR] With errors: 2 (8.0%)
```

### Critical Issues

```
CRITICAL ISSUES
===============
- app/pages/admin/users/index_page.rb
  - Database queries forbidden in Page
  - Missing required component method: table
```

### Warnings

```
WARNINGS
========
- app/pages/admin/users/show_page.rb
  - Hardcoded paths detected - prefer Rails path helpers
```

### Recommendations

```
RECOMMENDATIONS
===============
Top issues to address:
1. Database queries forbidden in Page (2 pages affected)
2. Missing required component method: header (1 pages affected)

NEXT STEPS:
1. Remove database queries from Pages
2. Remove business logic - keep UI configuration only
3. Implement required component methods for template system
```

## Programmatic Usage

```ruby
analyzer = BetterPage::Compliance::Analyzer.new

# Analyze single page
result = analyzer.analyze_page("app/pages/admin/users/index_page.rb")
puts result[:status]  # :compliant, :warning, or :error
puts result[:issues]  # Array of issue messages
puts result[:warnings]  # Array of warning messages

# Analyze all pages
analyzer.analyze_all
puts analyzer.compliant_count
puts analyzer.error_count
```
