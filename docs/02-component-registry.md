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
```

--------------------------------

### Implement Component Methods

Define methods matching the component names in your page class.

```ruby
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, current_user)
    @users = users
    @current_user = current_user
  end

  private

  def header
    { title: "Users", breadcrumbs: breadcrumbs_config }
  end

  def table
    { items: @users, columns: columns_config }
  end

  # Optional - uses default [] if not defined
  def statistics
    [{ label: "Total", value: @users.count, icon: "users" }]
  end
end
```

--------------------------------

### Build Page Method

The build_page method collects all registered components.

```ruby
def index
  build_page
end

# Returns:
# {
#   header: { title: "Users", breadcrumbs: [...] },
#   table: { items: [...], columns: [...] },
#   statistics: [...],
#   pagination: { enabled: false },
#   alerts: [],
#   ...
# }
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
  # Inherits from IndexBasePage: header, table, statistics, pagination
  # Inherits from ApplicationPage: alerts, footer
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
