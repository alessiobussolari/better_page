# Schema Validation

BetterPage uses [dry-schema](https://dry-rb.org/gems/dry-schema/) for component validation.

### String Type

```ruby
register_component :header, required: true do
  required(:title).filled(:string)
  optional(:subtitle).filled(:string)
end
```

--------------------------------

### Integer Type

```ruby
register_component :pagination do
  optional(:page).filled(:integer)
  optional(:per_page).filled(:integer)
end
```

--------------------------------

### Boolean Type

```ruby
register_component :tabs do
  optional(:enabled).filled(:bool)
end
```

--------------------------------

### Array Type

```ruby
register_component :header do
  optional(:breadcrumbs).array(:hash)
  optional(:actions).array(:hash)
end
```

--------------------------------

### Hash Type with Nested Schema

```ruby
register_component :table do
  optional(:empty_state).hash do
    optional(:icon).filled(:string)
    optional(:title).filled(:string)
    optional(:message).filled(:string)
  end
end
```

--------------------------------

### Required vs Optional Fields

```ruby
# Must be present and non-empty
required(:title).filled(:string)

# If present, must be non-empty string
optional(:subtitle).filled(:string)

# Array of hash objects
optional(:columns).array(:hash)
```

--------------------------------

### Complex Nested Structure

```ruby
register_component :footer do
  optional(:primary_action).hash do
    required(:label).filled(:string)
    optional(:style).filled(:string)
  end
  optional(:secondary_actions).array(:hash)
end
```

--------------------------------

### Header Component Schema Example

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

--------------------------------

### Table Component Schema Example

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

--------------------------------

### Validation Error Handling

```ruby
# Development - raises exception
BetterPage::ValidationError: Component :header validation failed: {:title=>["is missing"]}

# Production - logs warning
[BetterPage] Component :header validation failed: {:title=>["is missing"]}
```

--------------------------------

### Components Without Schema

Components can be registered without schema validation.

```ruby
register_component :alerts, default: []
register_component :custom_data, default: nil
```

These components accept any value without validation.
