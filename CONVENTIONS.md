# Project Conventions

This document outlines the conventions and rules used in this project for documentation, testing, and Context7 integration.

---

## 0. Required Project Structure

Every project MUST include the following three documentation folders:

| Folder | Purpose | Required |
|--------|---------|----------|
| `context7/` | Technical API documentation for Context7 integration | ✅ Yes |
| `docs/` | User-facing documentation | ✅ Yes |
| `guide/` | Tutorials, examples, and step-by-step guides | ✅ Yes |

**Rules:**
- All three folders are **mandatory** for project compliance
- Each folder must contain at minimum an `00-README.md` index file
- The `context7.json` configuration file must reference all three folders

---

## 2. Documentation Structure

### 2.1 Numbered File Naming

All documentation files use a numbered prefix for ordering:

```
00-README.md
01-getting-started.md
02-installation.md
03-configuration.md
...
```

**Rules:**
- Use two-digit prefix (00-99)
- Use lowercase with hyphens for the rest
- `00-README.md` is always the index/overview file
- Numbers determine display order in Context7

### 2.2 Folder Organization

```
project/
├── context7/          # Technical API documentation
│   ├── 00-README.md
│   ├── 01-base-page.md
│   └── ...
├── docs/              # User-facing documentation
│   ├── 00-README.md
│   ├── 01-getting-started.md
│   └── ...
└── guide/             # Tutorials and examples
    ├── 00-README.md
    ├── 01-quick-start.md
    └── ...
```

---

## 3. Context7 Documentation Format

### 3.1 Snippet Structure

Each code example follows this format:

```markdown
### Snippet Title

Brief description of what this code does and when to use it.

` ` `ruby
# Code example here
class Example
  def method
    # implementation
  end
end
` ` `

--------------------------------
```

**Rules:**
- Title uses `###` (h3) heading
- Description is 1-3 sentences
- Code block with appropriate language tag
- Separator line: `--------------------------------` (32 hyphens)
- Blank line after separator before next snippet

### 3.2 File Structure

Each documentation file should:

```markdown
# Main Title

Brief overview paragraph.

---

## Section 1

### Snippet Title

Description.

` ` `ruby
code
` ` `

--------------------------------

### Another Snippet

Description.

` ` `ruby
code
` ` `

--------------------------------

## Section 2

...
```

---

## 4. context7.json Configuration

### 4.1 Location

The `context7.json` file must be in the **project root** (not in subfolders).

### 4.2 Schema

```json
{
  "$schema": "https://context7.com/schema/context7.json",
  "projectTitle": "ProjectName",
  "description": "Brief project description.",
  "folders": ["context7", "docs", "guide"],
  "excludeFolders": ["spec", "tmp", "vendor", "node_modules"],
  "excludeFiles": [],
  "rules": [
    "Rule 1 - describe what must/must not be done",
    "Rule 2 - another constraint",
    "Rule 3 - etc."
  ]
}
```

### 4.3 Field Descriptions

| Field | Description |
|-------|-------------|
| `$schema` | Context7 schema URL (required) |
| `projectTitle` | Display name for the project |
| `description` | Brief description of the project |
| `folders` | Directories to include in documentation |
| `excludeFolders` | Directories to skip (tests, temp, etc.) |
| `excludeFiles` | Specific files to skip |
| `rules` | Project-specific constraints for AI assistants |

---

## 5. Testing with RSpec

### 5.1 Directory Structure

```
spec/
├── spec_helper.rb           # RSpec core configuration
├── rails_helper.rb          # Rails-specific configuration
├── rails_app/               # Test Rails application
│   ├── app/
│   ├── config/
│   └── db/
├── better_page/             # Unit tests by module
│   ├── base_page_spec.rb
│   ├── index_base_page_spec.rb
│   └── compliance/
│       └── analyzer_spec.rb
└── fixtures/                # Test data
```

### 5.2 Rails Helper Configuration

```ruby
# spec/rails_helper.rb
ENV["RAILS_ENV"] = "test"

require_relative "rails_app/config/environment"
ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("rails_app/db/migrate", __dir__)
]

require "rspec/rails"

RSpec.configure do |config|
  config.fixture_paths = [File.expand_path("fixtures", __dir__)]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
```

### 5.3 Test File Naming

- Suffix: `_spec.rb`
- Mirror source structure: `lib/better_page/base_page.rb` → `spec/better_page/base_page_spec.rb`

### 5.4 RSpec Style Guide

```ruby
RSpec.describe ClassName do
  # Use let for lazy-loaded test data
  let(:instance) { described_class.new }

  # Group related tests with describe
  describe "#method_name" do
    it "does something specific" do
      expect(result).to eq(expected)
    end

    context "when condition exists" do
      it "behaves differently" do
        expect(result).to be true
      end
    end
  end

  # For anonymous classes that need names, use stub_const
  describe "#resource_name" do
    it "extracts from class name" do
      stub_const("Products::NewPage", Class.new(BetterPage::FormBasePage) do
        def header; { title: "Test" }; end
        def panels; []; end
      end)

      page = Products::NewPage.new
      expect(page.send(:resource_name)).to eq("new")
    end
  end
end
```

### 5.5 Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific file
bundle exec rspec spec/better_page/base_page_spec.rb

# Run specific test by line
bundle exec rspec spec/better_page/base_page_spec.rb:42

# Run with verbose output
bundle exec rspec --format documentation
```

---

## 6. Gemfile Dependencies

For RSpec in a Rails engine:

```ruby
group :development, :test do
  gem "rspec-rails", "~> 7.0"
end
```

---

## 7. Quick Reference

| Item | Convention |
|------|------------|
| Required folders | `context7/`, `docs/`, `guide/` |
| Doc file naming | `NN-kebab-case.md` |
| Index file | `00-README.md` |
| Code snippets | h3 + description + code + separator |
| Separator | `--------------------------------` (32 chars) |
| context7.json | Root directory only |
| Test files | `*_spec.rb` |
| Test app | `spec/rails_app/` |
| Named test classes | Use `stub_const` |
