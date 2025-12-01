# Getting Started

### Install BetterPage Gem

Add BetterPage to your Rails application Gemfile.

```ruby
gem "better_page"
```

--------------------------------

### Run Bundle Install

Install the gem and its dependencies.

```bash
bundle install
```

--------------------------------

### Run Install Generator

Create the page infrastructure in your application.

```bash
rails generate better_page:install
```

This creates:
- `app/pages/application_page.rb` - Base page class
- `app/pages/index_base_page.rb` - Base for index pages
- `app/pages/show_base_page.rb` - Base for show pages
- `app/pages/form_base_page.rb` - Base for form pages
- `app/pages/custom_base_page.rb` - Base for custom pages
- `config/initializers/better_page.rb` - Configuration file
- `app/components/better_page/application_view_component.rb` - Base ViewComponent class (includes `Turbo::FramesHelper`)
- `app/components/better_page/` - ViewComponents for rendering pages

--------------------------------

### Generate Page Classes

Scaffold page classes for a resource with multiple actions.

```bash
rails generate better_page:page admin/users index show new edit
```

This creates:
- `app/pages/admin/users/index_page.rb`
- `app/pages/admin/users/show_page.rb`
- `app/pages/admin/users/new_page.rb`
- `app/pages/admin/users/edit_page.rb`

--------------------------------

### Basic Page Structure

Pages are presentation-layer classes that configure UI without business logic.

```ruby
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
      breadcrumbs: [{ label: "Home", path: "/" }],
      actions: [{ label: "New User", path: new_admin_user_path, icon: "plus" }]
    }
  end

  def table
    {
      items: @users,
      columns: [
        { key: :name, label: "Name", type: :link },
        { key: :email, label: "Email", type: :text }
      ],
      empty_state: { icon: "users", title: "No users", message: "No users found" }
    }
  end
end
```

--------------------------------

### Use Page in Controller

Instantiate the page and call the main action method.

```ruby
class Admin::UsersController < ApplicationController
  def index
    users = User.all
    @page = Admin::Users::IndexPage.new(users, user: current_user).index
  end

  def show
    user = User.find(params[:id])
    @page = Admin::Users::ShowPage.new(user, user: current_user).show
  end
end
```

--------------------------------

### Access Page Data in View

Use the @page hash to render UI components.

```erb
<h1><%= @page[:header][:title] %></h1>

<% @page[:table][:items].each do |user| %>
  <%= user.name %>
<% end %>
```

--------------------------------

### Architecture Rules

Pages must follow these rules:

1. **No database queries** - Data passed via constructor
2. **No business logic** - UI configuration only
3. **No service layer access** - No service objects
4. **Hash-only structures** - No OpenStruct/Struct
