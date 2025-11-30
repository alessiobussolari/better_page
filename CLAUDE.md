# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BetterPage is a Rails engine gem (requires Rails >= 8.1.1) that provides a structured page object pattern for separating UI configuration from business logic.

## Commands

### Install dependencies
```bash
bundle install
```

### Run tests
```bash
bundle exec rspec
```

### Run a single test file
```bash
bundle exec rspec spec/better_page_spec.rb
```

### Run tests with documentation format
```bash
bundle exec rspec --format documentation
```

### Lint code
```bash
bin/rubocop
```

### Auto-fix lint issues
```bash
bin/rubocop -a
```

## Architecture

### Core Classes (lib/better_page/)

- **base_page.rb** - `BetterPage::BasePage`: Base class with common helpers (count_text, format_date, percentage, empty_state_with_action)
- **index_base_page.rb** - `BetterPage::IndexBasePage`: For list pages (page_type :index)
- **show_base_page.rb** - `BetterPage::ShowBasePage`: For detail pages (page_type :show)
- **form_base_page.rb** - `BetterPage::FormBasePage`: For form pages (page_type :form)
- **custom_base_page.rb** - `BetterPage::CustomBasePage`: For custom pages (page_type :custom)
- **configuration.rb** - `BetterPage::Configuration`: Global component configuration
- **default_components.rb** - `BetterPage::DefaultComponents`: Registers all default components
- **component_registry.rb** - `BetterPage::ComponentRegistry`: DSL for component registration

### Page Inheritance Hierarchy

```
BetterPage::BasePage (gem)
        │
        ▼
ApplicationPage (app/pages/)
        │
        ├──▶ IndexBasePage (app/pages/ - page_type :index)
        ├──▶ ShowBasePage (app/pages/ - page_type :show)
        ├──▶ FormBasePage (app/pages/ - page_type :form)
        └──▶ CustomBasePage (app/pages/ - page_type :custom)
                │
                ▼
        Products::IndexPage, etc.
```

### Generators (lib/generators/better_page/)

- **install_generator.rb** - `rails g better_page:install`: Creates app/pages/, ApplicationPage, base page classes, and initializer
- **page_generator.rb** - `rails g better_page:page Namespace::Resource actions`: Generates page classes
- **sync_generator.rb** - `rails g better_page:sync`: Check for new components from gem updates

### Compliance (lib/better_page/compliance/)

- **analyzer.rb** - Validates pages follow architecture rules (no DB queries, no business logic, etc.)

### Rake Tasks (lib/tasks/)

- `rake better_page:analyze` - Analyze all pages
- `rake better_page:analyze_page[path]` - Analyze single page

## Page Rules

Pages must:
1. Only configure UI (Hash-based structures)
2. No database queries (.find, .where, .all, etc.)
3. No business logic (calculate_, process_, save_)
4. No service layer access
5. Use plain Hash objects (no OpenStruct)

Form pages: Checkbox and radio fields must be in separate panels from other input types.

## Usage Example

```ruby
# app/pages/admin/users/index_page.rb
module Admin
  module Users
    class IndexPage < IndexBasePage
      def initialize(users, user, params = {})
        @users = users
        @user = user
        @params = params
      end

      private

      def header
        { title: "Users", breadcrumbs: [], metadata: [], actions: [] }
      end

      def table
        { items: @users, columns: [], actions: nil, empty_state: {} }
      end
    end
  end
end
```

## Configuration

Components are registered at three levels:

1. **Gem defaults** - `BetterPage::DefaultComponents` registers all standard components
2. **User config** - `config/initializers/better_page.rb` for customization
3. **Local classes** - `register_component` in base or individual page classes

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  config.register_component :sidebar, default: { enabled: false }
  config.allow_components :index, :sidebar
end
```
