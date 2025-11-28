# Schema Validation

BetterPage uses [dry-schema](https://dry-rb.org/gems/dry-schema/) for component validation.

## Basic Types

### String

```ruby
register_component :header, required: true do
  required(:title).filled(:string)
  optional(:subtitle).filled(:string)
end
```

### Integer

```ruby
register_component :pagination do
  optional(:page).filled(:integer)
  optional(:per_page).filled(:integer)
end
```

### Boolean

```ruby
register_component :tabs do
  optional(:enabled).filled(:bool)
end
```

### Array

```ruby
register_component :header do
  optional(:breadcrumbs).array(:hash)
  optional(:actions).array(:hash)
end
```

### Hash

```ruby
register_component :table do
  optional(:empty_state).hash do
    optional(:icon).filled(:string)
    optional(:title).filled(:string)
    optional(:message).filled(:string)
  end
end
```

## Validation Rules

### Required Fields

```ruby
required(:title).filled(:string)  # Must be present and non-empty
```

### Optional Fields

```ruby
optional(:subtitle).filled(:string)  # If present, must be non-empty string
```

### Arrays of Hashes

```ruby
optional(:columns).array(:hash)  # Array of hash objects
```

### Nested Structures

```ruby
register_component :footer do
  optional(:primary_action).hash do
    required(:label).filled(:string)
    optional(:style).filled(:string)
  end
  optional(:secondary_actions).array(:hash)
end
```

## Examples

### Header Component

```ruby
register_component :header, required: true do
  required(:title).filled(:string)
  optional(:description).filled(:string)
  optional(:breadcrumbs).array(:hash)
  optional(:metadata).array(:hash)
  optional(:actions).array(:hash)
end
```

Valid:

```ruby
def header
  {
    title: "Users",
    breadcrumbs: [
      { label: "Home", path: "/" },
      { label: "Users", path: "/users" }
    ],
    actions: [
      { label: "New", path: "/users/new", icon: "plus" }
    ]
  }
end
```

Invalid (missing required title):

```ruby
def header
  { breadcrumbs: [...] }  # ValidationError: title is missing
end
```

### Table Component

```ruby
register_component :table, required: true do
  required(:items).value(:array)
  optional(:columns).array(:hash)
  optional(:actions)
  optional(:empty_state).hash do
    optional(:icon).filled(:string)
    optional(:title).filled(:string)
    optional(:message).filled(:string)
    optional(:action).hash
  end
end
```

Valid:

```ruby
def table
  {
    items: @users,
    columns: [
      { key: :name, label: "Name", type: :link },
      { key: :email, label: "Email", type: :text }
    ],
    empty_state: {
      icon: "users",
      title: "No users found",
      message: "Create your first user to get started"
    }
  }
end
```

### Pagination Component

```ruby
register_component :pagination, default: { enabled: false } do
  optional(:enabled).filled(:bool)
  optional(:page).filled(:integer)
  optional(:total_pages).filled(:integer)
  optional(:total_count).filled(:integer)
  optional(:per_page).filled(:integer)
end
```

Valid:

```ruby
def pagination
  {
    enabled: true,
    page: 1,
    total_pages: 10,
    total_count: 100,
    per_page: 10
  }
end
```

## Error Handling

In development, validation errors raise exceptions:

```ruby
# Development
BetterPage::ValidationError: Component :header validation failed: {:title=>["is missing"]}
```

In production, errors are logged as warnings:

```ruby
# Production
[BetterPage] Component :header validation failed: {:title=>["is missing"]}
```

## Components Without Schema

Components can be registered without schema validation:

```ruby
register_component :alerts, default: []
register_component :custom_data, default: nil
```

These components accept any value without validation.
