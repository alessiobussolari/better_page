# Base Pages Reference

BetterPage provides four base page classes for different page types.

## IndexBasePage

For list/index pages with tables.

### Registered Components

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | Yes | - | Page header with title, breadcrumbs, actions |
| `table` | Yes | - | Table with items, columns, actions |
| `alerts` | No | `[]` | Alert messages |
| `statistics` | No | `[]` | Statistic cards |
| `metrics` | No | `[]` | Metric displays |
| `tabs` | No | `{ enabled: false }` | Tab navigation |
| `search` | No | `{ enabled: false }` | Search configuration |
| `pagination` | No | `{ enabled: false }` | Pagination settings |
| `overview` | No | `{ enabled: false }` | Overview section |
| `calendar` | No | `{ enabled: false }` | Calendar view |
| `footer` | No | `{ enabled: false }` | Footer section |
| `modals` | No | `[]` | Modal configurations |
| `split_view` | No | `{ enabled: false }` | Split view layout |

### Example

```ruby
class Admin::Users::IndexPage < BetterPage::IndexBasePage
  def initialize(users, user)
    @users = users
    @user = user
  end

  def header
    { title: "Users", actions: [{ label: "New", path: new_admin_user_path }] }
  end

  def table
    { items: @users, columns: [...], empty_state: {...} }
  end

  def pagination
    { enabled: true, page: 1, total_pages: 10 }
  end
end
```

---

## ShowBasePage

For detail/show pages.

### Registered Components

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | Yes | - | Page header with title, metadata, actions |
| `alerts` | No | `[]` | Alert messages |
| `statistics` | No | `[]` | Statistic cards |
| `overview` | No | `{ enabled: false }` | Overview section |
| `content_sections` | No | `[]` | Content sections (info grids, text) |
| `footer` | No | `{ enabled: false }` | Footer section |

### Helper Methods

```ruby
# Convert hash to info grid format
info_grid_content_format({ "Name" => "John", "Email" => "john@example.com" })
# => [{ name: "Name", value: "John" }, { name: "Email", value: "john@example.com" }]

# Build content section
content_section_format(
  title: "Details",
  icon: "info",
  color: "blue",
  type: :info_grid,
  content: { "Name" => "John" }
)

# Build statistic
statistic_format(label: "Total", value: 100, icon: "users", color: "blue")

# Build action button
action_format(path: edit_path, label: "Edit", icon: "edit", style: "primary")
```

### Example

```ruby
class Admin::Users::ShowPage < BetterPage::ShowBasePage
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  def header
    { title: @user.name, actions: [action_format(path: edit_path, label: "Edit", icon: "edit", style: "primary")] }
  end

  def content_sections
    [
      content_section_format(
        title: "Profile",
        icon: "user",
        color: "blue",
        type: :info_grid,
        content: { "Email" => @user.email, "Role" => @user.role }
      )
    ]
  end
end
```

---

## FormBasePage

For new/edit form pages.

### Registered Components

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | Yes | - | Form header with title, description |
| `panels` | Yes | - | Form panels with fields |
| `alerts` | No | `[]` | Alert messages |
| `errors` | No | `nil` | Custom error configuration |
| `footer` | No | `{ primary_action: {...} }` | Form footer with buttons |

### Form Rules

**Important**: Checkbox and radio fields must be in separate panels:

```ruby
# CORRECT
def panels
  [
    { title: "Basic Info", fields: [{ name: :name, type: :text }, { name: :email, type: :email }] },
    { title: "Settings", fields: [{ name: :active, type: :checkbox }] }  # Separate panel
  ]
end

# WRONG - checkboxes mixed with text inputs
def panels
  [
    { title: "Info", fields: [{ name: :name, type: :text }, { name: :active, type: :checkbox }] }
  ]
end
```

### Helper Methods

```ruby
# Build a field
field_format(name: :email, type: :email, label: "Email", required: true)

# Build a panel
panel_format(title: "Basic Info", fields: [...], description: "Enter details")
```

### Example

```ruby
class Admin::Users::NewPage < BetterPage::FormBasePage
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  def header
    { title: "New User", description: "Create a new user account" }
  end

  def panels
    [
      panel_format(
        title: "Account Details",
        fields: [
          field_format(name: :email, type: :email, label: "Email", required: true),
          field_format(name: :name, type: :text, label: "Name", required: true)
        ]
      )
    ]
  end
end
```

---

## CustomBasePage

For custom pages that don't fit other patterns.

### Registered Components

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | No | `nil` | Optional page header |
| `content` | Yes | - | Custom content configuration |
| `footer` | No | `nil` | Optional footer |

### Helper Methods

```ruby
# Build a widget
widget_format(title: "Stats", type: :chart, data: {...})

# Build a chart
chart_format(title: "Revenue", type: :line, data: { labels: [...], datasets: [...] })
```

### Example

```ruby
class Admin::DashboardPage < BetterPage::CustomBasePage
  def initialize(data, user)
    @data = data
    @user = user
  end

  def header
    { title: "Dashboard" }
  end

  def content
    {
      widgets: [
        widget_format(title: "Users", type: :counter, data: { value: @data[:users_count] }),
        chart_format(title: "Revenue", type: :line, data: @data[:revenue_chart])
      ]
    }
  end
end
```
