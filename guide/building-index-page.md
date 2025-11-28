# Building an Index Page

A complete guide to building index/list pages with BetterPage.

## Overview

Index pages display collections of items in a table format with optional features like search, pagination, tabs, and statistics.

## Basic Structure

```ruby
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, current_user, params = {})
    @users = users
    @current_user = current_user
    @params = params
  end

  private

  def header
    { title: "Users", breadcrumbs: [], actions: [] }
  end

  def table
    { items: @users, columns: [], empty_state: {} }
  end
end
```

## Configuring the Header

The header contains the page title, breadcrumbs, metadata, and action buttons.

```ruby
def header
  {
    title: "Users Management",
    breadcrumbs: [
      { label: "Dashboard", path: admin_root_path },
      { label: "Users", path: admin_users_path, current: true }
    ],
    metadata: [
      { label: "Total", value: @users.size },
      { label: "Active", value: @users.count(&:active?) }
    ],
    actions: [
      { label: "Export", path: export_admin_users_path, icon: "download", style: "secondary" },
      { label: "New User", path: new_admin_user_path, icon: "plus", style: "primary" }
    ]
  }
end
```

## Configuring the Table

### Basic Table

```ruby
def table
  {
    items: @users,
    columns: [
      { key: :id, label: "ID", type: :text },
      { key: :name, label: "Name", type: :text },
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

### Column Types

```ruby
columns: [
  # Text column
  { key: :name, label: "Name", type: :text },

  # Link column
  { key: :name, label: "Name", type: :link, path: ->(item) { admin_user_path(item) } },

  # Badge column
  { key: :status, label: "Status", type: :badge },

  # Date column
  { key: :created_at, label: "Created", type: :date, format: "%d/%m/%Y" },

  # Currency column
  { key: :balance, label: "Balance", type: :currency },

  # Boolean column
  { key: :active, label: "Active", type: :boolean },

  # Custom column with block
  {
    key: :full_name,
    label: "Full Name",
    type: :custom,
    render: ->(item) { "#{item.first_name} #{item.last_name}" }
  }
]
```

### Row Actions

```ruby
def table
  {
    items: @users,
    columns: [...],
    actions: table_actions,
    empty_state: {...}
  }
end

def table_actions
  lambda { |item|
    actions = [
      { label: "View", path: admin_user_path(item), icon: "eye", style: "secondary" },
      { label: "Edit", path: edit_admin_user_path(item), icon: "edit", style: "secondary" }
    ]

    # Conditional actions
    if item.can_delete?
      actions << { label: "Delete", path: admin_user_path(item), icon: "trash", style: "danger", method: :delete }
    end

    actions
  }
end
```

## Adding Search

```ruby
def search
  {
    enabled: true,
    placeholder: "Search users by name or email...",
    current_search: @params[:q] || "",
    results_count: @users.size
  }
end
```

## Adding Pagination

```ruby
def pagination
  {
    enabled: true,
    page: @params[:page]&.to_i || 1,
    total_pages: (@users.total_count.to_f / 20).ceil,
    total_count: @users.total_count,
    per_page: 20
  }
end
```

## Adding Tabs

```ruby
def tabs
  {
    enabled: true,
    current_tab: @params[:status] || "all",
    tabs: [
      { key: "all", label: "All Users", count: @stats[:total], path: admin_users_path },
      { key: "active", label: "Active", count: @stats[:active], path: admin_users_path(status: "active") },
      { key: "inactive", label: "Inactive", count: @stats[:inactive], path: admin_users_path(status: "inactive") }
    ]
  }
end
```

## Adding Statistics

```ruby
def statistics
  [
    { label: "Total Users", value: @stats[:total], icon: "users", color: "blue" },
    { label: "Active", value: @stats[:active], icon: "check-circle", color: "green" },
    { label: "New This Month", value: @stats[:new_this_month], icon: "user-plus", color: "purple" }
  ]
end
```

## Complete Example

```ruby
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, current_user, stats, params)
    @users = users
    @current_user = current_user
    @stats = stats
    @params = params
  end

  private

  def header
    {
      title: "Users",
      breadcrumbs: [
        { label: "Admin", path: admin_root_path },
        { label: "Users", path: admin_users_path }
      ],
      actions: [
        { label: "New User", path: new_admin_user_path, icon: "plus", style: "primary" }
      ]
    }
  end

  def statistics
    [
      { label: "Total", value: @stats[:total], icon: "users", color: "blue" },
      { label: "Active", value: @stats[:active], icon: "check", color: "green" }
    ]
  end

  def tabs
    {
      enabled: true,
      current_tab: @params[:status] || "all",
      tabs: [
        { key: "all", label: "All", count: @stats[:total] },
        { key: "active", label: "Active", count: @stats[:active] }
      ]
    }
  end

  def search
    {
      enabled: true,
      placeholder: "Search users...",
      current_search: @params[:q] || ""
    }
  end

  def table
    {
      items: @users,
      columns: [
        { key: :name, label: "Name", type: :link, path: ->(u) { admin_user_path(u) } },
        { key: :email, label: "Email", type: :text },
        { key: :status, label: "Status", type: :badge },
        { key: :created_at, label: "Created", type: :date }
      ],
      actions: table_actions,
      empty_state: {
        icon: "users",
        title: "No users found",
        message: "Create your first user to get started",
        action: { label: "New User", path: new_admin_user_path }
      }
    }
  end

  def table_actions
    lambda { |user|
      [
        { label: "View", path: admin_user_path(user), icon: "eye" },
        { label: "Edit", path: edit_admin_user_path(user), icon: "edit" }
      ]
    }
  end

  def pagination
    {
      enabled: true,
      page: @params[:page]&.to_i || 1,
      total_pages: 10,
      per_page: 20
    }
  end
end
```
