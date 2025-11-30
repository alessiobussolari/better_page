# Component Registry

### Register Required Component with Schema

Use register_component DSL to declare components with dry-schema validation. Required components raise errors if nil.

```ruby
class BetterPage::IndexBasePage < BetterPage::BasePage
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
class BetterPage::IndexBasePage < BetterPage::BasePage
  register_component :alerts, default: []

  register_component :statistics, default: []

  register_component :pagination, default: { enabled: false } do
    optional(:enabled).filled(:bool)
    optional(:page).filled(:integer)
    optional(:total_pages).filled(:integer)
    optional(:per_page).filled(:integer)
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

### Validation Error Handling

Validation errors raise in development, log warnings in production.

```ruby
# Development - raises exception
BetterPage::ValidationError: Component :header validation failed: {:title=>["is missing"]}

# Production - logs warning
[BetterPage] Component :header validation failed: {:title=>["is missing"]}
```

--------------------------------

### Component Inheritance

Subclasses inherit all registered components from parent classes.

```ruby
class ApplicationPage < BetterPage::BasePage
  register_component :alerts, default: []
  register_component :footer, default: { enabled: false }
end

class Admin::Products::IndexPage < BetterPage::IndexBasePage
  # Inherits from IndexBasePage: header, table, statistics, pagination, etc.
  # Inherits from ApplicationPage: alerts, footer
end
```
