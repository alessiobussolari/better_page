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
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, current_user)
    @users = users
    @current_user = current_user
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
    @page = Admin::Users::IndexPage.new(users, current_user).index
  end
end
```

### Access in View

```erb
<h1><%= @page[:header][:title] %></h1>

<% @page[:table][:items].each do |user| %>
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

## Component Registration

Define components with schema validation:

```ruby
class BetterPage::IndexBasePage < BasePage
  register_component :header, required: true do
    required(:title).filled(:string)
    optional(:breadcrumbs).array(:hash)
    optional(:actions).array(:hash)
  end

  register_component :table, required: true do
    required(:items).value(:array)
    optional(:columns).array(:hash)
    optional(:empty_state).hash
  end

  register_component :pagination, default: { enabled: false }
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
