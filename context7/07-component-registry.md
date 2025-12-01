# Component Registry

### Three Levels of Component Registration

BetterPage uses a hybrid architecture with components registered at three levels.

```
Level 1: Global Config (config/initializers/better_page.rb)
    ↓
Level 2: Base Page Classes (app/pages/*_base_page.rb)
    ↓
Level 3: Individual Pages (app/pages/**/*_page.rb)
```

--------------------------------

### Global Configuration

Register components that apply to all page types in your initializer.

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  # Add global components
  config.register_component :alerts, default: []
  config.register_component :footer, default: { enabled: false }
end
```

--------------------------------

### Base Page Classes with page_type DSL

Use `page_type` to declare the page type and inherit default components.

```ruby
# app/pages/index_base_page.rb
class IndexBasePage < ApplicationPage
  page_type :index

  # Add components specific to index pages in your app
  register_component :quick_filters, default: []
end
```

--------------------------------

### Individual Page Override

Pages inherit all components and can override with custom values.

```ruby
class Admin::Users::IndexPage < IndexBasePage
  # Override inherited quick_filters
  register_component :quick_filters, default: [
    { label: "Active", field: :status, value: "active" }
  ]
end
```

--------------------------------

### Register Required Component with Schema

Use register_component DSL to declare components with dry-schema validation.

```ruby
class IndexBasePage < ApplicationPage
  page_type :index

  register_component :header, required: true do
    required(:title).filled(:string)
    optional(:description).filled(:string)
    optional(:breadcrumbs).array(:hash)
    optional(:actions).array(:hash)
  end

  register_component :table, required: true do
    required(:items).value(:array)
    optional(:columns).array(:hash)
    optional(:empty_state).hash
  end
end
```

--------------------------------

### Register Optional Component with Default

Optional components use default values when not defined.

```ruby
class IndexBasePage < ApplicationPage
  page_type :index

  register_component :alerts, default: []
  register_component :statistics, default: []

  register_component :pagination, default: { enabled: false } do
    optional(:enabled).filled(:bool)
    optional(:page).filled(:integer)
    optional(:total_pages).filled(:integer)
  end

  register_component :search, default: { enabled: false }
  register_component :tabs, default: { enabled: false }
end
```

--------------------------------

### Schema Validation Types

Available dry-schema types for component validation.

```ruby
register_component :example do
  # String
  required(:title).filled(:string)
  optional(:description).filled(:string)

  # Integer
  optional(:count).filled(:integer)

  # Boolean
  optional(:enabled).filled(:bool)

  # Array
  optional(:items).value(:array)
  optional(:tags).array(:string)

  # Array of Hashes
  optional(:columns).array(:hash)

  # Nested Hash
  optional(:empty_state).hash do
    optional(:icon).filled(:string)
    optional(:title).filled(:string)
    optional(:message).filled(:string)
  end
end
```

--------------------------------

### Component Inheritance

Subclasses inherit all registered components from parent classes.

```ruby
# Inheritance chain:
# BetterPage::BasePage -> ApplicationPage -> IndexBasePage -> Admin::Products::IndexPage

class Admin::Products::IndexPage < IndexBasePage
  # Inherits from IndexBasePage: header, table, statistics, pagination, etc.
  # Inherits from ApplicationPage: alerts, footer (global)
end
```

--------------------------------

### Validation Error Handling

Validation errors raise in development, log warnings in production.

```ruby
# Development - raises exception
BetterPage::ValidationError: Component :header validation failed: {:title=>["is missing"]}

# Production - logs warning
[BetterPage] Component :header validation failed: {:title=>["is missing"]}
```
