# Building a Form Page

A complete guide to building new/edit form pages with BetterPage.

## Overview

Form pages provide configuration for creating and editing records with panels, fields, and validation display.

## Basic Structure

```ruby
class Admin::Users::NewPage < BetterPage::FormBasePage
  def initialize(user, current_user)
    @user = user
    @current_user = current_user
  end

  private

  def header
    { title: "New User", description: "Create a new user account" }
  end

  def panels
    [{ title: "Basic Information", fields: [] }]
  end
end
```

## Configuring the Header

```ruby
def header
  {
    title: @user.new_record? ? "New User" : "Edit #{@user.name}",
    description: @user.new_record? ? "Create a new user account" : "Update user information",
    breadcrumbs: [
      { label: "Admin", path: admin_root_path },
      { label: "Users", path: admin_users_path },
      { label: @user.new_record? ? "New" : @user.name }
    ]
  }
end
```

## Building Panels

### Basic Panel

```ruby
def panels
  [
    {
      title: "Basic Information",
      fields: [
        { name: :name, type: :text, label: "Name", required: true },
        { name: :email, type: :email, label: "Email", required: true }
      ]
    }
  ]
end
```

### Using Helper Methods

```ruby
def panels
  [
    panel_format(
      title: "Account Details",
      description: "Basic account information",
      fields: [
        field_format(name: :name, type: :text, label: "Name", required: true),
        field_format(name: :email, type: :email, label: "Email", required: true)
      ]
    )
  ]
end
```

## Field Types

### Text Fields

```ruby
{ name: :name, type: :text, label: "Name", required: true, placeholder: "Enter name" }
{ name: :email, type: :email, label: "Email" }
{ name: :phone, type: :tel, label: "Phone" }
{ name: :website, type: :url, label: "Website" }
{ name: :age, type: :number, label: "Age", min: 0, max: 120 }
```

### Text Area

```ruby
{ name: :bio, type: :textarea, label: "Bio", rows: 5 }
```

### Select

```ruby
{
  name: :role,
  type: :select,
  label: "Role",
  collection: [
    { value: "admin", label: "Administrator" },
    { value: "manager", label: "Manager" },
    { value: "user", label: "User" }
  ]
}
```

### Checkbox (must be in separate panel!)

```ruby
{ name: :active, type: :checkbox, label: "Active user" }
{ name: :newsletter, type: :checkbox, label: "Subscribe to newsletter" }
```

### Radio Buttons (must be in separate panel!)

```ruby
{
  name: :notification_preference,
  type: :radio,
  label: "Notification Preference",
  options: [
    { value: "email", label: "Email" },
    { value: "sms", label: "SMS" },
    { value: "none", label: "None" }
  ]
}
```

### Date/Time

```ruby
{ name: :birth_date, type: :date, label: "Birth Date" }
{ name: :appointment, type: :datetime, label: "Appointment" }
{ name: :start_time, type: :time, label: "Start Time" }
```

### File Upload

```ruby
{ name: :avatar, type: :file, label: "Avatar", accept: "image/*" }
```

### Hidden

```ruby
{ name: :status, type: :hidden, value: "pending" }
```

## Panel Organization Rules

**Important**: Checkbox and radio fields MUST be in separate panels.

### Correct

```ruby
def panels
  [
    # Text inputs panel
    panel_format(
      title: "Account Details",
      fields: [
        field_format(name: :name, type: :text, label: "Name"),
        field_format(name: :email, type: :email, label: "Email")
      ]
    ),
    # Checkboxes in separate panel
    panel_format(
      title: "Settings",
      fields: [
        field_format(name: :active, type: :checkbox, label: "Active"),
        field_format(name: :newsletter, type: :checkbox, label: "Newsletter")
      ]
    )
  ]
end
```

### Wrong (will trigger warning)

```ruby
def panels
  [
    panel_format(
      title: "Details",
      fields: [
        field_format(name: :name, type: :text, label: "Name"),
        field_format(name: :active, type: :checkbox, label: "Active")  # WRONG!
      ]
    )
  ]
end
```

## Configuring the Footer

```ruby
def footer
  {
    primary_action: {
      label: @user.new_record? ? "Create User" : "Save Changes",
      style: :primary
    },
    secondary_actions: [
      { label: "Cancel", path: admin_users_path, style: :secondary }
    ],
    info: "Required fields are marked with *"
  }
end
```

## Adding Alerts

```ruby
def alerts
  return [] if @user.new_record?

  [
    {
      type: :info,
      title: "Editing existing user",
      message: "Changes will be applied immediately after saving."
    }
  ]
end
```

## Complete Example

```ruby
class Admin::Users::EditPage < BetterPage::FormBasePage
  def initialize(user, current_user, roles)
    @user = user
    @current_user = current_user
    @roles = roles
  end

  private

  def header
    {
      title: "Edit #{@user.name}",
      description: "Update user account information",
      breadcrumbs: [
        { label: "Admin", path: admin_root_path },
        { label: "Users", path: admin_users_path },
        { label: @user.name, path: admin_user_path(@user) },
        { label: "Edit" }
      ]
    }
  end

  def alerts
    alerts = []

    if @user.suspended?
      alerts << {
        type: :warning,
        title: "Account suspended",
        message: "This user account is currently suspended."
      }
    end

    alerts
  end

  def panels
    [
      panel_format(
        title: "Account Details",
        icon: "user",
        description: "Basic account information",
        fields: [
          field_format(name: :name, type: :text, label: "Name", required: true),
          field_format(name: :email, type: :email, label: "Email", required: true),
          field_format(name: :phone, type: :tel, label: "Phone"),
          field_format(
            name: :role,
            type: :select,
            label: "Role",
            collection: @roles.map { |r| { value: r.id, label: r.name } }
          )
        ]
      ),
      panel_format(
        title: "Profile",
        icon: "file-text",
        fields: [
          field_format(name: :bio, type: :textarea, label: "Bio", rows: 4),
          field_format(name: :avatar, type: :file, label: "Avatar", accept: "image/*")
        ]
      ),
      panel_format(
        title: "Settings",
        icon: "settings",
        fields: [
          field_format(name: :active, type: :checkbox, label: "Active account"),
          field_format(name: :email_notifications, type: :checkbox, label: "Email notifications"),
          field_format(name: :two_factor, type: :checkbox, label: "Two-factor authentication")
        ]
      )
    ]
  end

  def footer
    {
      primary_action: { label: "Save Changes", style: :primary },
      secondary_actions: [
        { label: "Cancel", path: admin_user_path(@user), style: :secondary }
      ]
    }
  end
end
```
