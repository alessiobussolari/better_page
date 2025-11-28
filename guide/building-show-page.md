# Building a Show Page

A complete guide to building detail/show pages with BetterPage.

## Overview

Show pages display detailed information about a single record with sections, statistics, and actions.

## Basic Structure

```ruby
class Admin::Users::ShowPage < BetterPage::ShowBasePage
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  private

  def header
    { title: @user.name, breadcrumbs: [], actions: [] }
  end
end
```

## Configuring the Header

```ruby
def header
  {
    title: @user.name,
    breadcrumbs: [
      { label: "Admin", path: admin_root_path },
      { label: "Users", path: admin_users_path },
      { label: @user.name, path: admin_user_path(@user), current: true }
    ],
    metadata: [
      { label: "ID", value: "##{@user.id}" },
      { label: "Created", value: format_date(@user.created_at) },
      { label: "Status", value: @user.status, type: :badge }
    ],
    actions: [
      { label: "Edit", path: edit_admin_user_path(@user), icon: "edit", style: "primary" },
      { label: "Delete", path: admin_user_path(@user), icon: "trash", style: "danger", method: :delete }
    ]
  }
end
```

## Adding Statistics

```ruby
def statistics
  [
    statistic_format(
      label: "Orders",
      value: @stats[:orders_count],
      icon: "shopping-cart",
      color: "blue"
    ),
    statistic_format(
      label: "Total Spent",
      value: number_to_currency(@stats[:total_spent]),
      icon: "dollar-sign",
      color: "green"
    ),
    statistic_format(
      label: "Last Order",
      value: format_date(@stats[:last_order_date]),
      icon: "calendar",
      color: "purple"
    )
  ]
end
```

## Adding Content Sections

Content sections display information in different formats.

### Info Grid Section

```ruby
def content_sections
  [
    content_section_format(
      title: "Profile Information",
      icon: "user",
      color: "blue",
      type: :info_grid,
      content: {
        "Email" => @user.email,
        "Phone" => @user.phone || "Not provided",
        "Role" => @user.role.titleize,
        "Created" => format_date(@user.created_at),
        "Last Login" => format_date(@user.last_sign_in_at)
      }
    )
  ]
end
```

### Pre-formatted Info Grid

```ruby
content_section_format(
  title: "Details",
  icon: "info",
  color: "blue",
  type: :info_grid,
  content: [
    { name: "Name", value: @user.name },
    { name: "Email", value: @user.email },
    { name: "Status", value: @user.status, type: :badge }
  ]
)
```

### Text Content Section

```ruby
content_section_format(
  title: "Bio",
  icon: "file-text",
  color: "gray",
  type: :text_content,
  content: @user.bio || "No bio provided"
)
```

### Custom Section

```ruby
content_section_format(
  title: "Recent Activity",
  icon: "activity",
  color: "purple",
  type: :custom,
  content: {
    activities: @recent_activities.map do |activity|
      { description: activity.description, timestamp: activity.created_at }
    end
  }
)
```

## Multiple Content Sections

```ruby
def content_sections
  [
    # Profile section
    content_section_format(
      title: "Profile",
      icon: "user",
      color: "blue",
      type: :info_grid,
      content: profile_info
    ),

    # Address section
    content_section_format(
      title: "Address",
      icon: "map-pin",
      color: "green",
      type: :info_grid,
      content: address_info
    ),

    # Preferences section
    content_section_format(
      title: "Preferences",
      icon: "settings",
      color: "purple",
      type: :info_grid,
      content: preferences_info
    )
  ]
end

private

def profile_info
  {
    "Name" => @user.name,
    "Email" => @user.email,
    "Phone" => @user.phone
  }
end

def address_info
  {
    "Street" => @user.street,
    "City" => @user.city,
    "Country" => @user.country
  }
end

def preferences_info
  {
    "Language" => @user.language,
    "Timezone" => @user.timezone,
    "Notifications" => @user.notifications_enabled? ? "Enabled" : "Disabled"
  }
end
```

## Adding Alerts

```ruby
def alerts
  alerts = []

  if @user.email_unverified?
    alerts << {
      type: :warning,
      title: "Email not verified",
      message: "This user has not verified their email address."
    }
  end

  if @user.suspended?
    alerts << {
      type: :error,
      title: "Account suspended",
      message: "This account has been suspended."
    }
  end

  alerts
end
```

## Complete Example

```ruby
class Admin::Users::ShowPage < BetterPage::ShowBasePage
  def initialize(user, current_user, stats)
    @user = user
    @current_user = current_user
    @stats = stats
  end

  private

  def header
    {
      title: @user.name,
      breadcrumbs: [
        { label: "Admin", path: admin_root_path },
        { label: "Users", path: admin_users_path },
        { label: @user.name, path: admin_user_path(@user) }
      ],
      metadata: [
        { label: "ID", value: "##{@user.id}" },
        { label: "Status", value: @user.status, type: :badge }
      ],
      actions: [
        action_format(path: edit_admin_user_path(@user), label: "Edit", icon: "edit", style: "primary")
      ]
    }
  end

  def alerts
    return [] unless @user.suspended?

    [{ type: :error, title: "Suspended", message: "This account is suspended." }]
  end

  def statistics
    [
      statistic_format(label: "Orders", value: @stats[:orders], icon: "shopping-cart", color: "blue"),
      statistic_format(label: "Spent", value: "$#{@stats[:spent]}", icon: "dollar-sign", color: "green")
    ]
  end

  def content_sections
    [
      content_section_format(
        title: "Profile",
        icon: "user",
        color: "blue",
        type: :info_grid,
        content: {
          "Email" => @user.email,
          "Phone" => @user.phone,
          "Role" => @user.role,
          "Created" => format_date(@user.created_at)
        }
      ),
      content_section_format(
        title: "Address",
        icon: "map-pin",
        color: "green",
        type: :info_grid,
        content: {
          "Street" => @user.street,
          "City" => @user.city,
          "Country" => @user.country
        }
      )
    ]
  end
end
```
