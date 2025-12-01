# Custom Page

### Define a Custom Dashboard Page

Create a CustomPage for dashboards, reports, or any non-standard layout. Content is required.

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
        widget_format(title: "Orders", type: :counter, data: { value: @data[:orders_count] }),
        chart_format(title: "Revenue", type: :line, data: @data[:revenue_chart])
      ]
    }
  end
end
```

--------------------------------

### Custom Page with Charts

Add multiple chart types to your dashboard.

```ruby
class Reports::SalesPage < CustomBasePage
  def initialize(sales_data, metadata = {})
    @sales_data = sales_data
    @user = metadata[:user]
    super(sales_data, metadata)
  end

  private

  def header
    { title: "Sales Report" }
  end

  def content
    {
      widgets: [
        chart_format(
          title: "Monthly Revenue",
          type: :line,
          data: {
            labels: @sales_data[:months],
            datasets: [
              { label: "Revenue", data: @sales_data[:revenue] }
            ]
          }
        ),
        chart_format(
          title: "Sales by Category",
          type: :pie,
          data: {
            labels: @sales_data[:categories],
            datasets: [
              { data: @sales_data[:category_totals] }
            ]
          }
        )
      ]
    }
  end
end
```

--------------------------------

### Custom Page Helper Methods

Available helper methods for CustomBasePage:

```ruby
# Build a widget
widget_format(
  title: "Users",
  type: :counter,  # :counter, :chart, :list
  data: { value: 1234 }
)

# Build a chart
chart_format(
  title: "Revenue",
  type: :line,     # :line, :bar, :pie, :doughnut
  data: {
    labels: ["Jan", "Feb", "Mar"],
    datasets: [{ label: "Sales", data: [100, 200, 150] }]
  }
)
```
