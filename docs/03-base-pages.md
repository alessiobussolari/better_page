# Base Pages Reference

### Page Types Overview

BetterPage provides four base page classes, generated locally in your `app/pages/` folder.

| Type | Base Class | Required Components | Use Case |
|------|-----------|---------------------|----------|
| Index | `IndexBasePage` | `header`, `table` | List views |
| Show | `ShowBasePage` | `header` | Detail views |
| Form | `FormBasePage` | `header`, `panels` | New/Edit forms |
| Custom | `CustomBasePage` | `content` | Dashboards, reports |

### Inheritance Hierarchy

```
BetterPage::BasePage (gem)
        │
        ▼
ApplicationPage (app/pages/)
        │
        ├── IndexBasePage (page_type :index)
        ├── ShowBasePage (page_type :show)
        ├── FormBasePage (page_type :form)
        └── CustomBasePage (page_type :custom)
```

--------------------------------

### IndexBasePage Components

Components available for list/index pages.

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
| `footer` | No | `{ enabled: false }` | Footer section |

--------------------------------

### IndexBasePage Example

```ruby
class Admin::Users::IndexPage < IndexBasePage
  def initialize(users, metadata = {})
    @users = users
    @user = metadata[:user]
    super(users, metadata)
  end

  private

  def header
    { title: "Users", actions: [{ label: "New", path: new_admin_user_path }] }
  end

  def table
    { items: @users, columns: table_columns, empty_state: empty_config }
  end

  def statistics
    [
      { label: "Total", value: @users.size, icon: "users" },
      { label: "Active", value: @users.count(&:active?), icon: "check" }
    ]
  end

  def pagination
    { enabled: true, page: 1, total_pages: 10 }
  end
end
```

--------------------------------

### ShowBasePage Components

Components available for detail/show pages.

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | Yes | - | Page header with title, metadata, actions |
| `alerts` | No | `[]` | Alert messages |
| `statistics` | No | `[]` | Statistic cards |
| `overview` | No | `{ enabled: false }` | Overview section |
| `content_sections` | No | `[]` | Content sections (info grids, text) |
| `footer` | No | `{ enabled: false }` | Footer section |

--------------------------------

### ShowBasePage Helper Methods

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

--------------------------------

### FormBasePage Components

Components available for new/edit form pages.

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | Yes | - | Form header with title, description |
| `panels` | Yes | - | Form panels with fields |
| `alerts` | No | `[]` | Alert messages |
| `errors` | No | `nil` | Custom error configuration |
| `footer` | No | `{ primary_action: {...} }` | Form footer with buttons |

--------------------------------

### FormBasePage Helper Methods

```ruby
# Build a field
field_format(name: :email, type: :email, label: "Email", required: true)

# Build a panel
panel_format(title: "Basic Info", fields: [...], description: "Enter details")
```

**Important**: Checkbox and radio fields must be in separate panels.

--------------------------------

### FormBasePage Example

```ruby
class Admin::Users::NewPage < FormBasePage
  def initialize(user, metadata = {})
    @user = user
    @current_user = metadata[:user]
    super(user, metadata)
  end

  private

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
      ),
      panel_format(
        title: "Settings",
        fields: [
          field_format(name: :active, type: :checkbox, label: "Active")
        ]
      )
    ]
  end
end
```

--------------------------------

### CustomBasePage Components

Components available for custom pages.

| Component | Required | Default | Description |
|-----------|----------|---------|-------------|
| `header` | No | `nil` | Optional page header |
| `content` | Yes | - | Custom content configuration |
| `footer` | No | `nil` | Optional footer |

--------------------------------

### CustomBasePage Helper Methods

```ruby
# Build a widget
widget_format(title: "Stats", type: :chart, data: {...})

# Build a chart
chart_format(title: "Revenue", type: :line, data: { labels: [...], datasets: [...] })
```

--------------------------------

### CustomBasePage Example

```ruby
class Admin::DashboardPage < CustomBasePage
  def initialize(data, metadata = {})
    @data = data
    @user = metadata[:user]
    super(data, metadata)
  end

  private

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
