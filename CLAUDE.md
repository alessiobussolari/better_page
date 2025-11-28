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
bin/test
```

### Run a single test file
```bash
bin/test test/better_page_test.rb
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
- **index_base_page.rb** - `BetterPage::IndexBasePage`: For list pages (requires: build_index_header, build_index_table)
- **show_base_page.rb** - `BetterPage::ShowBasePage`: For detail pages (requires: build_show_header)
- **form_base_page.rb** - `BetterPage::FormBasePage`: For form pages (requires: build_form_header, build_form_panels)
- **custom_base_page.rb** - `BetterPage::CustomBasePage`: For custom pages (requires: build_custom_content)

### Generators (lib/generators/better_page/)

- **install_generator.rb** - `rails g better_page:install`: Creates app/pages/ and ApplicationPage
- **page_generator.rb** - `rails g better_page:page Namespace::Resource actions`: Generates page classes

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
    class IndexPage < BetterPage::IndexBasePage
      def initialize(users, user, params = {})
        @users = users
        @user = user
        @params = params
      end

      private

      def build_index_header
        { title: "Users", breadcrumbs: [], metadata: [], actions: [] }
      end

      def build_index_table
        { items: @users, columns: [], actions: nil, empty_state: {} }
      end
    end
  end
end
```
