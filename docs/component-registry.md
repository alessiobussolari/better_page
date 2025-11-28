# Component Registry

The Component Registry is the core system that allows pages to declare and validate their components using a DSL.

## How It Works

Components are registered at the class level using `register_component`:

```ruby
class BetterPage::IndexBasePage < BasePage
  register_component :header, required: true do
    required(:title).filled(:string)
    optional(:breadcrumbs).array(:hash)
    optional(:metadata).array(:hash)
    optional(:actions).array(:hash)
  end

  register_component :table, required: true do
    required(:items).value(:array)
    optional(:columns).array(:hash)
    optional(:actions)
    optional(:empty_state).hash
  end

  register_component :statistics, default: []
  register_component :pagination, default: { enabled: false }
end
```

## Registration Options

### Required Components

```ruby
register_component :header, required: true do
  required(:title).filled(:string)
end
```

If a required component returns `nil`, a `BetterPage::ValidationError` is raised in development.

### Optional Components with Defaults

```ruby
register_component :alerts, default: []
register_component :footer, default: { enabled: false }
```

If the component method is not defined, the default value is used.

### Schema Validation

Use dry-schema syntax to define validation rules:

```ruby
register_component :pagination, default: { enabled: false } do
  optional(:enabled).filled(:bool)
  optional(:page).filled(:integer)
  optional(:total_pages).filled(:integer)
  optional(:per_page).filled(:integer)
end
```

## Implementing Components

In your page class, define methods matching the component names:

```ruby
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def header
    {
      title: "Users",
      breadcrumbs: breadcrumbs_config
    }
  end

  def table
    {
      items: @users,
      columns: columns_config
    }
  end

  # Optional - if not defined, uses default []
  def statistics
    [
      { label: "Total", value: @users.count, icon: "users" }
    ]
  end
end
```

## Building the Page

The `build_page` method collects all registered components:

```ruby
def index
  build_page
end
```

Returns:

```ruby
{
  header: { title: "Users", breadcrumbs: [...] },
  table: { items: [...], columns: [...] },
  statistics: [...],
  pagination: { enabled: false },
  # ... other components with defaults
}
```

## Inheritance

Subclasses inherit all registered components from parent classes:

```ruby
class ApplicationPage < BetterPage::BasePage
  # Custom components for your app
end

class Admin::Users::IndexPage < BetterPage::IndexBasePage
  # Inherits: header, table, statistics, pagination, etc.
end
```

## Validation Behavior

- **Development**: Raises `BetterPage::ValidationError` on validation failure
- **Production**: Logs a warning and continues

```ruby
# Customize in component_registry.rb
def handle_validation_error(message)
  if Rails.env.development?
    raise BetterPage::ValidationError, message
  else
    Rails.logger.warn "[BetterPage] #{message}"
  end
end
```
