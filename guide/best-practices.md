# Best Practices

Patterns and recommendations for using BetterPage effectively.

## Architecture Principles

### 1. Pages Are Pure Presentation

Pages should only configure UI. Never put business logic in pages.

```ruby
# GOOD - Data comes from outside
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, stats, current_user)
    @users = users
    @stats = stats
    @current_user = current_user
  end

  def statistics
    [
      { label: "Total", value: @stats[:total] },
      { label: "Active", value: @stats[:active] }
    ]
  end
end

# BAD - Business logic in page
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def statistics
    [
      { label: "Total", value: User.count },  # Database query!
      { label: "Active", value: User.where(active: true).count }  # Database query!
    ]
  end
end
```

### 2. Prepare Data in Controllers

Controllers should prepare all data before creating pages.

```ruby
# GOOD
class Admin::UsersController < ApplicationController
  def index
    users = User.includes(:role).order(:name)
    stats = {
      total: User.count,
      active: User.where(active: true).count,
      new_this_month: User.where("created_at > ?", 1.month.ago).count
    }
    @page = Admin::Users::IndexPage.new(users, stats, current_user).index
  end
end
```

### 3. Use Services for Complex Data

For complex data preparation, use service objects.

```ruby
class Admin::DashboardController < ApplicationController
  def index
    data = DashboardDataService.new(current_user).call
    @page = Admin::DashboardPage.new(data, current_user).custom
  end
end

class DashboardDataService
  def initialize(user)
    @user = user
  end

  def call
    {
      users_count: User.count,
      orders_count: Order.count,
      revenue: Order.sum(:total),
      recent_activities: Activity.recent.limit(10)
    }
  end
end
```

## Code Organization

### 1. Keep Pages Focused

Each page should have a single responsibility.

```ruby
# GOOD - Focused page
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  # Only handles user listing
end

class Admin::Users::ShowPage < BetterPage::ShowBasePage
  # Only handles user detail view
end

# BAD - Page doing too much
class Admin::UsersPage < BetterPage::BasePage
  def index; end
  def show; end
  def new; end
  def edit; end
end
```

### 2. Extract Reusable Methods

Move common patterns to a shared base page.

```ruby
class ApplicationPage < BetterPage::BasePage
  protected

  def standard_breadcrumbs(items)
    [{ label: "Home", path: root_path }] + items
  end

  def format_currency(amount)
    "$#{amount.round(2)}"
  end

  def user_avatar_url(user)
    user.avatar.attached? ? url_for(user.avatar) : default_avatar_url
  end
end

class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def header
    {
      title: "Users",
      breadcrumbs: standard_breadcrumbs([{ label: "Users" }])
    }
  end
end
```

### 3. Use Constants for Repeated Values

```ruby
class Admin::Orders::IndexPage < BetterPage::IndexBasePage
  STATUS_COLORS = {
    pending: "yellow",
    processing: "blue",
    shipped: "purple",
    delivered: "green",
    cancelled: "red"
  }.freeze

  STATUS_ICONS = {
    pending: "clock",
    processing: "refresh",
    shipped: "truck",
    delivered: "check",
    cancelled: "x"
  }.freeze

  def table
    {
      items: @orders,
      columns: [
        {
          key: :status,
          label: "Status",
          type: :badge,
          color: ->(order) { STATUS_COLORS[order.status.to_sym] },
          icon: ->(order) { STATUS_ICONS[order.status.to_sym] }
        }
      ]
    }
  end
end
```

## Testing Pages

### 1. Unit Test Page Output

```ruby
require "test_helper"

class Admin::Users::IndexPageTest < ActiveSupport::TestCase
  setup do
    @users = [create(:user), create(:user)]
    @stats = { total: 2, active: 1 }
    @current_user = create(:admin)
  end

  test "returns correct header" do
    page = Admin::Users::IndexPage.new(@users, @stats, @current_user)
    result = page.index

    assert_equal "Users", result[:header][:title]
    assert_includes result[:header][:actions].map { |a| a[:label] }, "New User"
  end

  test "returns table with users" do
    page = Admin::Users::IndexPage.new(@users, @stats, @current_user)
    result = page.index

    assert_equal @users, result[:table][:items]
  end

  test "returns statistics" do
    page = Admin::Users::IndexPage.new(@users, @stats, @current_user)
    result = page.index

    assert_equal 2, result[:statistics].find { |s| s[:label] == "Total" }[:value]
  end
end
```

### 2. Test Component Methods

```ruby
test "header includes edit action for existing user" do
  user = create(:user)
  page = Admin::Users::ShowPage.new(user, @current_user)
  result = page.show

  edit_action = result[:header][:actions].find { |a| a[:label] == "Edit" }
  assert_not_nil edit_action
  assert_equal edit_admin_user_path(user), edit_action[:path]
end
```

## Performance Tips

### 1. Avoid N+1 in Pages

Ensure data is properly eager-loaded before passing to pages.

```ruby
# GOOD - Eager loading in controller
def index
  users = User.includes(:role, :department).order(:name)
  @page = Admin::Users::IndexPage.new(users, stats, current_user).index
end

# Page can safely access associations
def table
  {
    items: @users,
    columns: [
      { key: :name, label: "Name" },
      { key: ->(u) { u.role.name }, label: "Role" },  # No N+1
      { key: ->(u) { u.department.name }, label: "Dept" }  # No N+1
    ]
  }
end
```

### 2. Precompute Statistics

```ruby
# GOOD - Stats computed once in controller
stats = {
  total: users.size,  # No extra query
  by_role: users.group_by(&:role).transform_values(&:size)
}

# BAD - Computing in page
def statistics
  [
    { label: "Admins", value: @users.count { |u| u.role == "admin" } }  # O(n) every render
  ]
end
```

## Common Patterns

### 1. Conditional Actions

```ruby
def header
  {
    title: @user.name,
    actions: header_actions
  }
end

def header_actions
  actions = []

  if can?(:edit, @user)
    actions << { label: "Edit", path: edit_path, icon: "edit" }
  end

  if can?(:delete, @user) && @user.deletable?
    actions << { label: "Delete", path: delete_path, icon: "trash", method: :delete }
  end

  actions
end
```

### 2. Dynamic Columns

```ruby
def table
  {
    items: @users,
    columns: build_columns
  }
end

def build_columns
  columns = [
    { key: :name, label: "Name", type: :link }
  ]

  if @current_user.admin?
    columns << { key: :email, label: "Email" }
    columns << { key: :role, label: "Role" }
  end

  columns << { key: :created_at, label: "Created", type: :date }
  columns
end
```

### 3. Reusable Empty States

```ruby
class ApplicationPage < BetterPage::BasePage
  protected

  def empty_state_for(resource, options = {})
    {
      icon: options[:icon] || "inbox",
      title: options[:title] || "No #{resource.pluralize} found",
      message: options[:message] || "There are no #{resource.pluralize} to display.",
      action: options[:action]
    }
  end
end

class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def table
    {
      items: @users,
      columns: [...],
      empty_state: empty_state_for("user",
        action: { label: "New User", path: new_admin_user_path }
      )
    }
  end
end
```
