# Getting Started with BetterPage

BetterPage is a Rails engine that provides a structured Page Object pattern for building UI configurations without business logic.

## Installation

Add to your Gemfile:

```ruby
gem "better_page"
```

Run bundle:

```bash
bundle install
```

Run the install generator:

```bash
rails generate better_page:install
```

This creates:
- `app/pages/application_page.rb` - Base page class for your application

## Basic Usage

### Creating a Page

Use the page generator:

```bash
rails generate better_page:page admin/users index show new edit
```

This creates:
- `app/pages/admin/users/index_page.rb`
- `app/pages/admin/users/show_page.rb`
- `app/pages/admin/users/new_page.rb`
- `app/pages/admin/users/edit_page.rb`

### Using Pages in Controllers

```ruby
class Admin::UsersController < ApplicationController
  def index
    users = User.all
    @page = Admin::Users::IndexPage.new(users, current_user).index
  end

  def show
    user = User.find(params[:id])
    @page = Admin::Users::ShowPage.new(user, current_user).show
  end
end
```

### Page Structure

Pages are presentation-layer classes that configure UI without business logic:

```ruby
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, user)
    @users = users
    @user = user
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
      empty_state: {
        icon: "users",
        title: "No users",
        message: "No users found"
      }
    }
  end
end
```

## Architecture Rules

Pages must follow these rules:

1. **No database queries** - Data is passed in via constructor
2. **No business logic** - Pages only configure UI
3. **No service layer access** - No service objects
4. **Hash-based structures only** - No OpenStruct

## Running Compliance Check

```bash
rake better_page:compliance:analyze
```

This validates all pages follow architecture rules.
