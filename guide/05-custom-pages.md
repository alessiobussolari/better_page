# Building Custom Pages

A complete guide to building dashboards, reports, and other custom pages.

### Basic Custom Page Structure

```ruby
class Admin::DashboardPage < BetterPage::CustomBasePage
  def initialize(data, current_user)
    @data = data
    @current_user = current_user
  end

  private

  def build_custom_header
    { title: "Dashboard" }
  end

  def build_custom_content
    { widgets: [] }
  end
end
```

--------------------------------

### Adding Widgets

```ruby
def build_custom_content
  {
    widgets: [
      widget_format(title: "Total Users", type: :counter, data: { value: @data[:users_count] }),
      widget_format(title: "Total Orders", type: :counter, data: { value: @data[:orders_count] }),
      widget_format(title: "Revenue", type: :counter, data: { value: format_currency(@data[:revenue]) })
    ]
  }
end
```

--------------------------------

### Using widget_format Helper

Build widgets with the helper method.

```ruby
widget_format(
  title: "Active Users",
  type: :counter,        # :counter, :chart, :list, :table
  data: { value: 1234 },
  color: "blue",
  icon: "users"
)
```

--------------------------------

### Adding Charts

```ruby
def build_custom_content
  {
    widgets: [
      chart_format(
        title: "Revenue Over Time",
        type: :line,
        data: {
          labels: @data[:months],
          datasets: [
            { label: "Revenue", data: @data[:revenue_by_month], color: "blue" }
          ]
        }
      )
    ]
  }
end
```

--------------------------------

### Using chart_format Helper

Build charts with the helper method.

```ruby
chart_format(
  title: "Sales Chart",
  type: :line,           # :line, :bar, :pie, :doughnut, :area
  data: {
    labels: ["Jan", "Feb", "Mar", "Apr"],
    datasets: [
      { label: "Sales", data: [100, 200, 150, 300], color: "blue" },
      { label: "Returns", data: [10, 20, 15, 30], color: "red" }
    ]
  }
)
```

--------------------------------

### Chart Types

```ruby
# Line Chart
chart_format(title: "Trend", type: :line, data: chart_data)

# Bar Chart
chart_format(title: "Comparison", type: :bar, data: chart_data)

# Pie Chart
chart_format(title: "Distribution", type: :pie, data: pie_data)

# Doughnut Chart
chart_format(title: "Breakdown", type: :doughnut, data: pie_data)

# Area Chart
chart_format(title: "Growth", type: :area, data: chart_data)
```

--------------------------------

### Adding List Widget

```ruby
def build_custom_content
  {
    widgets: [
      widget_format(
        title: "Recent Orders",
        type: :list,
        data: {
          items: @data[:recent_orders].map do |order|
            {
              title: "Order ##{order.id}",
              subtitle: order.customer_name,
              value: format_currency(order.total),
              path: order_path(order)
            }
          end
        }
      )
    ]
  }
end
```

--------------------------------

### Adding Table Widget

```ruby
def build_custom_content
  {
    widgets: [
      widget_format(
        title: "Top Products",
        type: :table,
        data: {
          columns: [
            { key: :name, label: "Product" },
            { key: :sales, label: "Sales" },
            { key: :revenue, label: "Revenue" }
          ],
          rows: @data[:top_products]
        }
      )
    ]
  }
end
```

--------------------------------

### Dashboard with Grid Layout

```ruby
def build_custom_content
  {
    layout: :grid,
    columns: 3,
    widgets: [
      # Row 1: Statistics
      widget_format(title: "Users", type: :counter, data: { value: @data[:users] }),
      widget_format(title: "Orders", type: :counter, data: { value: @data[:orders] }),
      widget_format(title: "Revenue", type: :counter, data: { value: @data[:revenue] }),

      # Row 2: Charts (span 2 columns)
      chart_format(title: "Sales Trend", type: :line, data: sales_chart_data, span: 2),
      chart_format(title: "Categories", type: :pie, data: category_chart_data, span: 1),

      # Row 3: Lists
      widget_format(title: "Recent Orders", type: :list, data: orders_data, span: 2),
      widget_format(title: "Top Products", type: :list, data: products_data, span: 1)
    ]
  }
end
```

--------------------------------

### Reports Page Example

```ruby
class Reports::SalesPage < BetterPage::CustomBasePage
  def initialize(report_data, current_user, period:)
    @report_data = report_data
    @current_user = current_user
    @period = period
  end

  private

  def build_custom_header
    {
      title: "Sales Report",
      description: "Sales performance for #{@period}",
      actions: [
        { label: "Export PDF", path: export_report_path(format: :pdf), icon: "download" },
        { label: "Export CSV", path: export_report_path(format: :csv), icon: "file" }
      ]
    }
  end

  def build_custom_content
    {
      widgets: [
        # Summary statistics
        widget_format(title: "Total Sales", type: :counter, data: { value: @report_data[:total_sales] }),
        widget_format(title: "Orders", type: :counter, data: { value: @report_data[:order_count] }),
        widget_format(title: "Avg Order Value", type: :counter, data: { value: @report_data[:avg_order] }),

        # Charts
        chart_format(title: "Daily Sales", type: :line, data: daily_sales_data),
        chart_format(title: "Sales by Category", type: :pie, data: category_data),

        # Tables
        widget_format(title: "Top Selling Products", type: :table, data: top_products_data)
      ]
    }
  end

  def daily_sales_data
    {
      labels: @report_data[:dates],
      datasets: [{ label: "Sales", data: @report_data[:daily_totals], color: "blue" }]
    }
  end

  def category_data
    {
      labels: @report_data[:categories].keys,
      datasets: [{ data: @report_data[:categories].values }]
    }
  end

  def top_products_data
    {
      columns: [
        { key: :name, label: "Product" },
        { key: :quantity, label: "Qty Sold" },
        { key: :revenue, label: "Revenue" }
      ],
      rows: @report_data[:top_products]
    }
  end
end
```

--------------------------------

### Complete Dashboard Example

```ruby
class Admin::DashboardPage < BetterPage::CustomBasePage
  def initialize(stats, current_user)
    @stats = stats
    @current_user = current_user
  end

  private

  def build_custom_header
    {
      title: "Dashboard",
      description: "Welcome back, #{@current_user.name}"
    }
  end

  def build_custom_content
    {
      layout: :grid,
      columns: 4,
      widgets: statistics_widgets + chart_widgets + list_widgets
    }
  end

  def statistics_widgets
    [
      widget_format(title: "Users", type: :counter, data: { value: @stats[:users], change: "+12%" }, icon: "users", color: "blue"),
      widget_format(title: "Orders", type: :counter, data: { value: @stats[:orders], change: "+8%" }, icon: "cart", color: "green"),
      widget_format(title: "Revenue", type: :counter, data: { value: format_currency(@stats[:revenue]), change: "+15%" }, icon: "dollar", color: "purple"),
      widget_format(title: "Conversion", type: :counter, data: { value: "#{@stats[:conversion]}%", change: "-2%" }, icon: "chart", color: "yellow")
    ]
  end

  def chart_widgets
    [
      chart_format(title: "Revenue Trend", type: :area, data: revenue_chart_data, span: 2),
      chart_format(title: "Orders by Status", type: :doughnut, data: orders_chart_data, span: 2)
    ]
  end

  def list_widgets
    [
      widget_format(title: "Recent Orders", type: :list, data: { items: recent_orders }, span: 2),
      widget_format(title: "Low Stock", type: :list, data: { items: low_stock_items }, span: 2)
    ]
  end
end
```
