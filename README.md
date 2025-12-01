# BetterPage

A Rails engine that provides a structured Page Object pattern for building UI configurations. Pages are presentation-layer classes that configure UI without business logic, making your views cleaner and more maintainable.

## Features

- **Component Registration DSL** - Declare UI components with schema validation using dry-schema
- **Multiple Page Types** - Index, Show, Form, and Custom page base classes
- **Schema Validation** - Automatic validation of component data in development
- **Turbo Support** - Built-in support for Turbo Frames and Turbo Streams
- **Compliance Analyzer** - Ensure pages follow architecture rules
- **Rails Generators** - Quickly scaffold new pages

## Installation

Add to your Gemfile:

```ruby
gem "better_page"
```

Run:

```bash
bundle install
rails generate better_page:install
```

## Quick Start

### Generate a Page

```bash
rails generate better_page:page admin/users index show new edit
```

### Define a Page

```ruby
# app/pages/admin/users/index_page.rb
class Admin::Users::IndexPage < IndexBasePage
  def initialize(users, metadata = {})
    @users = users
    @user = metadata[:user]
    super(users, metadata)
  end

  private

  def header
    {
      title: "Users",
      breadcrumbs: [{ label: "Admin", path: admin_root_path }],
      actions: [{ label: "New User", path: new_admin_user_path, icon: "plus" }]
    }
  end

  def table
    {
      items: @users,
      columns: [
        { key: :name, label: "Name", type: :link, path: ->(u) { admin_user_path(u) } },
        { key: :email, label: "Email", type: :text }
      ],
      empty_state: { icon: "users", title: "No users", message: "Create your first user" }
    }
  end
end
```

### Use in Controller

```ruby
class Admin::UsersController < ApplicationController
  def index
    users = User.all.order(:name)
    @config = Admin::Users::IndexPage.new(users, user: current_user).index
    # @config is a BetterPage::Config object
  end
end
```

### Access in View

```erb
<%# Direct method access %>
<h1><%= @config.header[:title] %></h1>

<%# Hash-like access (backward compatible) %>
<h1><%= @config[:header][:title] %></h1>

<% @config.table[:items].each do |user| %>
  <%= user.name %>
<% end %>
```

## Page Types

| Type | Base Class | Required Components | Use Case |
|------|-----------|---------------------|----------|
| Index | `IndexBasePage` | `header`, `table` | List views |
| Show | `ShowBasePage` | `header` | Detail views |
| Form | `FormBasePage` | `header`, `panels` | New/Edit forms |
| Custom | `CustomBasePage` | `content` | Dashboards, reports |

## BetterPage::Config

When you call a page action (e.g., `page.index`, `page.show`), it returns a `BetterPage::Config` object. This follows the same pattern as `BetterService::Result` and `BetterController::Result`.

### Structure

```ruby
config = Admin::Users::IndexPage.new(users, user: current_user).index

config.components  # => Hash of all component configurations
config.meta        # => { page_type: :index, klass: IndexViewComponent }
```

### Component Access

```ruby
# Direct method access
config.header            # => { title: "Users", breadcrumbs: [...] }
config.table             # => { items: [...], columns: [...] }
config.statistics        # => [{ label: "Total", value: 100 }]

# Hash-like access (backward compatible)
config[:header][:title]  # => "Users"
config.dig(:header, :breadcrumbs, 0, :label)  # => "Admin"
```

### Meta Access

```ruby
config.page_type  # => :index, :show, :form, :custom
config.klass      # => ViewComponent class for rendering
```

### Destructuring

```ruby
# Supports destructuring like BetterService::Result
components, meta = config

components[:header][:title]  # => "Users"
meta[:page_type]             # => :index
```

### Component Helpers

```ruby
# Check if component is present (not nil/empty)
config.component?(:header)      # => true
config.component?(:pagination)  # => false if empty

# List all component names
config.component_names  # => [:header, :table, :statistics, ...]

# Get only present (non-empty) components
config.present_components  # => { header: {...}, table: {...} }

# Iterate over components
config.each_component do |name, value|
  puts "#{name}: #{value}"
end
```

### Hash-like Interface

For backward compatibility, Config supports full hash-like access:

```ruby
config[:header]           # => { title: "Users", ... }
config.key?(:header)      # => true
config.dig(:table, :items, 0)  # => first item
```

## Configuration

BetterPage uses a hybrid configuration system. Default components are registered by the gem, and you can customize them in your initializer:

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  # Add a custom global component
  config.register_component :sidebar, default: { enabled: false }
  config.allow_components :index, :sidebar

  # Override a default component
  config.register_component :pagination, default: { enabled: true, per_page: 25 }
end
```

### Check for Updates

When upgrading BetterPage, check for new components:

```bash
rails generate better_page:sync
```

## Component Registration

Components can be registered at three levels:

### 1. Global Configuration (Initializer)

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  config.register_component :sidebar, default: { enabled: false } do
    optional(:enabled).filled(:bool)
    optional(:items).array(:hash)
  end
  config.allow_components :index, :sidebar
end
```

### 2. Base Page Classes (Local)

```ruby
# app/pages/index_base_page.rb
class IndexBasePage < ApplicationPage
  page_type :index

  # Add component only for index pages
  register_component :quick_filters, default: []
end
```

### 3. Individual Pages

```ruby
# app/pages/admin/users/index_page.rb
class Admin::Users::IndexPage < IndexBasePage
  # Component only for this specific page
  register_component :user_stats, default: nil

  def user_stats
    { active_count: @users.active.count }
  end
end
```

## Architecture Rules

Pages must follow these rules (enforced by compliance analyzer):

1. **No database queries** - Data passed via constructor
2. **No business logic** - UI configuration only
3. **No service layer access** - No service objects
4. **Hash-only structures** - No OpenStruct/Struct

Run compliance check:

```bash
rake better_page:compliance:analyze
```

## ViewComponent Architecture

All UI components inherit from `ApplicationViewComponent`:

```
ViewComponent::Base
       │
       ▼
BetterPage::ApplicationViewComponent (includes Turbo::FramesHelper)
       │
       ├── IndexViewComponent
       ├── ShowViewComponent
       ├── FormViewComponent
       ├── CustomViewComponent
       └── Ui::* (Header, Table, Drawer, Modal, etc.)
```

The `ApplicationViewComponent` base class includes `Turbo::FramesHelper`, making Turbo helpers available in all component templates.

## Turbo Support

BetterPage provides built-in support for Turbo Frames and Turbo Streams.

### Turbo Frame (Single Component)

```ruby
# Controller - lazy load table
def table
  component = Products::IndexPage.new(@products, current_user).frame_index(:table)
  render component[:klass].new(**component[:config])
end
```

### Turbo Stream (Multiple Components)

```ruby
# Controller - update multiple components
def refresh
  components = Products::IndexPage.new(@products, current_user).stream_index(:table, :statistics)

  render turbo_stream: components.map { |c|
    turbo_stream.replace(c[:target], c[:klass].new(**c[:config]))
  }
end
```

Dynamic methods are generated based on your page's main action: `frame_index`, `stream_index`, `frame_show`, `stream_show`, etc.

## Lookbook (Component Preview)

BetterPage includes [Lookbook](https://lookbook.build/) for previewing ViewComponents in development.

```bash
cd spec/rails_app && bin/rails server -p 3099
```

Open http://localhost:3099/lookbook to browse component previews.

## Documentation

- **[docs/](docs/)** - API reference and technical documentation
- **[guide/](guide/)** - Step-by-step guides and tutorials

### Quick Links

- [Getting Started](docs/01-getting-started.md)
- [Component Registry](docs/02-component-registry.md)
- [Base Pages Reference](docs/03-base-pages.md)
- [Schema Validation](docs/04-schema-validation.md)
- [Turbo Support](docs/05-turbo-support.md)
- [Compliance Analyzer](docs/06-compliance-analyzer.md)
- [Configuration](docs/07-configuration.md)
- [Quick Start Guide](guide/01-quick-start.md)
- [Building Index Pages](guide/02-building-index-page.md)
- [Building Form Pages](guide/04-building-form-page.md)
- [Best Practices](guide/06-best-practices.md)

## Requirements

- Ruby >= 3.0
- Rails >= 8.1
- dry-schema ~> 1.13

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Author

Alessio Bussolari <alessio.bussolari@pandev.it>
