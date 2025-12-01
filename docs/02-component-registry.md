# Component Registry

BetterPage uses a hybrid component registration system with three levels.

### Registration Levels

Components can be registered at three levels:

1. **Global Configuration** - In `config/initializers/better_page.rb`
2. **Base Page Classes** - In local base pages like `IndexBasePage`
3. **Individual Pages** - In specific page classes

--------------------------------

### Global Configuration (Initializer)

Register components globally in your initializer. These are available to all pages of the mapped type.

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  # Add a custom component with schema
  config.register_component :sidebar, default: { enabled: false } do
    optional(:enabled).filled(:bool)
    optional(:items).array(:hash)
  end

  # Map to page types
  config.allow_components :index, :sidebar
  config.allow_components :show, :sidebar

  # Make required for specific page types
  config.require_components :index, :sidebar
end
```

--------------------------------

### Base Page Classes (page_type DSL)

Local base classes use `page_type` to inherit components from global configuration.

```ruby
# app/pages/index_base_page.rb
class IndexBasePage < ApplicationPage
  page_type :index

  # Add component only for index pages
  register_component :quick_filters, default: []
end
```

--------------------------------

### Individual Pages

Register components specific to a single page.

```ruby
class Admin::Users::IndexPage < IndexBasePage
  # Component only for this page
  register_component :user_stats, default: nil

  def user_stats
    { active_count: @users.active.count }
  end
end
```

--------------------------------

### Register Component with Schema

Use dry-schema for validation. Required components raise errors if nil.

```ruby
register_component :header, required: true do
  required(:title).filled(:string)
  optional(:description).filled(:string)
  optional(:breadcrumbs).array(:hash)
  optional(:actions).array(:hash)
end
```

--------------------------------

### Register Optional Component with Default

Optional components use default values when method is not defined.

```ruby
register_component :alerts, default: []

register_component :pagination, default: { enabled: false } do
  optional(:enabled).filled(:bool)
  optional(:page).filled(:integer)
  optional(:total_pages).filled(:integer)
end
```

--------------------------------

### Implement Component Methods

Define methods matching the component names in your page class.

```ruby
class Admin::Users::IndexPage < IndexBasePage
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

Components are inherited through the class hierarchy and merged with global configuration.

```ruby
# Global configuration provides components for each page_type
# app/pages/index_base_page.rb inherits from ApplicationPage and uses page_type :index
# Individual pages inherit from their base class

class Admin::Products::IndexPage < IndexBasePage
  # Gets components from:
  # 1. Global config mapped to :index (header, table, statistics, pagination, etc.)
  # 2. IndexBasePage local components
  # 3. ApplicationPage components (alerts, footer)
end
```

### Check for New Components

When upgrading BetterPage, check for new default components:

```bash
rails generate better_page:sync
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
