# Custom Pages

A guide to building dashboards and custom pages that don't fit standard patterns.

## Overview

Custom pages are for views that don't fit the index/show/form patterns, such as dashboards, reports, and specialized views.

## Basic Structure

```ruby
class Admin::DashboardPage < BetterPage::CustomBasePage
  def initialize(data, current_user)
    @data = data
    @current_user = current_user
  end

  private

  def header
    { title: "Dashboard" }
  end

  def content
    { widgets: [], charts: [] }
  end
end
```

## Building a Dashboard

### Header Configuration

```ruby
def header
  {
    title: "Dashboard",
    breadcrumbs: [
      { label: "Admin", path: admin_root_path },
      { label: "Dashboard", path: admin_dashboard_path }
    ],
    metadata: [
      { label: "Last updated", value: format_date(Time.current) }
    ],
    actions: [
      { label: "Refresh", path: admin_dashboard_path, icon: "refresh" },
      { label: "Export", path: export_admin_dashboard_path, icon: "download" }
    ]
  }
end
```

### Content with Widgets

```ruby
def content
  {
    summary_cards: summary_cards,
    charts: charts,
    recent_activity: recent_activity,
    quick_actions: quick_actions
  }
end

private

def summary_cards
  [
    widget_format(
      title: "Total Users",
      type: :counter,
      data: {
        value: @data[:users_count],
        change: @data[:users_change],
        trend: :up
      }
    ),
    widget_format(
      title: "Revenue",
      type: :currency,
      data: {
        value: @data[:revenue],
        change: @data[:revenue_change],
        trend: :up
      }
    ),
    widget_format(
      title: "Orders",
      type: :counter,
      data: {
        value: @data[:orders_count],
        change: @data[:orders_change],
        trend: :down
      }
    )
  ]
end
```

### Adding Charts

```ruby
def charts
  [
    chart_format(
      title: "Revenue Over Time",
      type: :line,
      data: {
        labels: @data[:revenue_labels],
        datasets: [
          {
            label: "Revenue",
            data: @data[:revenue_values],
            color: "blue"
          }
        ]
      }
    ),
    chart_format(
      title: "Orders by Category",
      type: :pie,
      data: {
        labels: @data[:category_labels],
        values: @data[:category_values]
      }
    ),
    chart_format(
      title: "Monthly Comparison",
      type: :bar,
      data: {
        labels: @data[:months],
        datasets: [
          { label: "This Year", data: @data[:this_year], color: "blue" },
          { label: "Last Year", data: @data[:last_year], color: "gray" }
        ]
      }
    )
  ]
end
```

### Recent Activity List

```ruby
def recent_activity
  {
    title: "Recent Activity",
    items: @data[:activities].map do |activity|
      {
        icon: activity_icon(activity.type),
        title: activity.title,
        description: activity.description,
        timestamp: format_date(activity.created_at, "%H:%M"),
        user: activity.user.name
      }
    end
  }
end

def activity_icon(type)
  case type
  when "order" then "shopping-cart"
  when "user" then "user"
  when "payment" then "credit-card"
  else "activity"
  end
end
```

### Quick Actions

```ruby
def quick_actions
  [
    { label: "New Order", path: new_admin_order_path, icon: "plus", color: "blue" },
    { label: "Add User", path: new_admin_user_path, icon: "user-plus", color: "green" },
    { label: "View Reports", path: admin_reports_path, icon: "bar-chart", color: "purple" }
  ]
end
```

## Building a Report Page

```ruby
class Admin::Reports::SalesReportPage < BetterPage::CustomBasePage
  def initialize(report_data, filters, current_user)
    @report = report_data
    @filters = filters
    @current_user = current_user
  end

  private

  def header
    {
      title: "Sales Report",
      breadcrumbs: [
        { label: "Admin", path: admin_root_path },
        { label: "Reports", path: admin_reports_path },
        { label: "Sales Report" }
      ],
      metadata: [
        { label: "Period", value: "#{@filters[:start_date]} - #{@filters[:end_date]}" }
      ],
      actions: [
        { label: "Export PDF", path: export_pdf_path, icon: "file-pdf" },
        { label: "Export CSV", path: export_csv_path, icon: "file-csv" }
      ]
    }
  end

  def content
    {
      filters: filters_config,
      summary: summary_section,
      breakdown: breakdown_section,
      trends: trends_section
    }
  end

  def filters_config
    {
      date_range: {
        start: @filters[:start_date],
        end: @filters[:end_date]
      },
      categories: @filters[:categories],
      regions: @filters[:regions]
    }
  end

  def summary_section
    {
      title: "Summary",
      metrics: [
        { label: "Total Sales", value: @report[:total_sales], format: :currency },
        { label: "Orders", value: @report[:total_orders], format: :number },
        { label: "Average Order", value: @report[:average_order], format: :currency },
        { label: "Growth", value: @report[:growth], format: :percentage }
      ]
    }
  end

  def breakdown_section
    {
      title: "Sales by Category",
      type: :table,
      columns: ["Category", "Sales", "Orders", "% of Total"],
      rows: @report[:by_category].map do |cat|
        [cat[:name], cat[:sales], cat[:orders], cat[:percentage]]
      end
    }
  end

  def trends_section
    chart_format(
      title: "Sales Trend",
      type: :line,
      data: {
        labels: @report[:trend_labels],
        datasets: [{ label: "Sales", data: @report[:trend_values] }]
      }
    )
  end
end
```

## Building a Settings Page

```ruby
class Admin::SettingsPage < BetterPage::CustomBasePage
  def initialize(settings, current_user)
    @settings = settings
    @current_user = current_user
  end

  private

  def header
    {
      title: "Settings",
      breadcrumbs: [
        { label: "Admin", path: admin_root_path },
        { label: "Settings" }
      ]
    }
  end

  def content
    {
      sections: [
        general_settings,
        notification_settings,
        security_settings,
        integration_settings
      ]
    }
  end

  def general_settings
    {
      title: "General",
      icon: "settings",
      description: "Basic application settings",
      fields: [
        { name: "site_name", label: "Site Name", value: @settings[:site_name], type: :text },
        { name: "timezone", label: "Timezone", value: @settings[:timezone], type: :select },
        { name: "language", label: "Language", value: @settings[:language], type: :select }
      ]
    }
  end

  def notification_settings
    {
      title: "Notifications",
      icon: "bell",
      description: "Email and push notification preferences",
      fields: [
        { name: "email_notifications", label: "Email notifications", value: @settings[:email_notifications], type: :toggle },
        { name: "push_notifications", label: "Push notifications", value: @settings[:push_notifications], type: :toggle }
      ]
    }
  end

  def security_settings
    {
      title: "Security",
      icon: "shield",
      description: "Security and authentication settings",
      fields: [
        { name: "two_factor", label: "Two-factor authentication", value: @settings[:two_factor], type: :toggle },
        { name: "session_timeout", label: "Session timeout (minutes)", value: @settings[:session_timeout], type: :number }
      ]
    }
  end

  def integration_settings
    {
      title: "Integrations",
      icon: "plug",
      description: "Third-party integrations",
      items: @settings[:integrations].map do |integration|
        {
          name: integration[:name],
          icon: integration[:icon],
          status: integration[:connected] ? :connected : :disconnected,
          action: integration[:connected] ? "Disconnect" : "Connect"
        }
      end
    }
  end
end
```

## Controller Usage

```ruby
class Admin::DashboardController < ApplicationController
  def index
    data = DashboardDataService.new(current_user).call
    @page = Admin::DashboardPage.new(data, current_user).custom
  end
end
```
