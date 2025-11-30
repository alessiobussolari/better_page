# Compliance

### Run Compliance Analyzer

Validate that all pages follow architecture rules.

```bash
rake better_page:compliance:analyze
```

--------------------------------

### Run Compliance in Verbose Mode

Get detailed output for each analyzed page.

```bash
VERBOSE=true rake better_page:compliance:analyze
```

--------------------------------

### Architecture Rules

Pages must follow these rules enforced by the compliance analyzer:

1. **No database queries** - Data passed via constructor
2. **No business logic** - UI configuration only
3. **No service layer access** - No service objects
4. **Hash-only structures** - No OpenStruct/Struct
5. **Separate panels for checkboxes** - Checkbox/radio fields in separate panels

--------------------------------

### Forbidden Database Patterns

These patterns are NOT allowed in pages.

```ruby
# WRONG - Database queries in page
def header
  { title: "#{User.count} Users" }  # Database query forbidden
end

def table
  { items: User.where(active: true) }  # Database query forbidden
end

# CORRECT - Data passed via constructor
def initialize(users, stats)
  @users = users
  @stats = stats
end

def header
  { title: "#{@stats[:count]} Users" }
end

def table
  { items: @users }
end
```

--------------------------------

### Forbidden Business Logic Patterns

These patterns are NOT allowed in pages.

```ruby
# WRONG - Business logic in page
def calculate_total      # Business calculation
def process_data         # Business processing
def validate_user        # Validation logic
def save_record          # Persistence

# WRONG - Service access
def header
  result = UserService.new.get_stats  # Service access forbidden
  { title: result[:title] }
end
```

--------------------------------

### Forbidden External Dependencies

These patterns are NOT allowed in pages.

```ruby
# WRONG - External HTTP clients
Net::HTTP.get(...)
HTTParty.get(...)
Faraday.get(...)

# WRONG - External services
Redis.current.get(...)
```

--------------------------------

### Required Component Methods by Page Type

Each page type must implement required methods.

| Page Type | Required Methods |
|-----------|-----------------|
| IndexPage | `header`, `table` |
| ShowPage | `header` |
| FormPage | `header`, `panels` |
| CustomPage | `content` |

--------------------------------

### Compliance Report Output

The analyzer generates a summary report.

```
SUMMARY
=======
Total pages analyzed: 25
[OK] Fully compliant: 20 (80.0%)
[WARN] With warnings: 3 (12.0%)
[ERROR] With errors: 2 (8.0%)

CRITICAL ISSUES
===============
- app/pages/admin/users/index_page.rb
  - Database queries forbidden in Page
  - Missing required component method: table

RECOMMENDATIONS
===============
1. Remove database queries from Pages
2. Remove business logic - keep UI configuration only
3. Implement required component methods
```

--------------------------------

### Programmatic Compliance Usage

Use the analyzer programmatically in tests or scripts.

```ruby
analyzer = BetterPage::Compliance::Analyzer.new

# Analyze single page
result = analyzer.analyze_page("app/pages/admin/users/index_page.rb")
puts result[:status]    # :compliant, :warning, or :error
puts result[:issues]    # Array of issue messages
puts result[:warnings]  # Array of warning messages

# Analyze all pages
analyzer.analyze_all
puts analyzer.compliant_count
puts analyzer.error_count
```
