# Best Practices

Guidelines for building maintainable and compliant pages.

### Keep Pages Thin

Pages should only configure UI. Move complex logic to the controller or service layer.

```ruby
# WRONG - Logic in page
class Products::IndexPage < IndexBasePage
  def statistics
    total = @products.sum(&:price) * 1.1  # Tax calculation
    [{ label: "Total", value: total }]
  end
end

# CORRECT - Logic in controller
class ProductsController < ApplicationController
  def index
    products = Product.all
    stats = { total_with_tax: ProductCalculator.total_with_tax(products) }
    @page = Products::IndexPage.new(products, user: current_user, stats: stats).index
  end
end

class Products::IndexPage < IndexBasePage
  def initialize(products, metadata = {})
    @products = products
    @user = metadata[:user]
    @stats = metadata[:stats]
    super(products, metadata)
  end

  def statistics
    [{ label: "Total", value: @stats[:total_with_tax] }]
  end
end
```

--------------------------------

### Pass All Data via Constructor

Never query the database in a page. All data should be passed through the constructor.

```ruby
# WRONG - Database query in page
def header
  { title: "#{User.count} Users" }
end

# CORRECT - Data passed via constructor
def initialize(users, metadata = {})
  @users = users
  @user = metadata[:user]
  @stats = metadata[:stats]
  super(users, metadata)
end

def header
  { title: "#{@stats[:count]} Users" }
end
```

--------------------------------

### Use Helper Methods for Reusable Configurations

Extract repeated configurations into private helper methods.

```ruby
class Products::IndexPage < IndexBasePage
  private

  def header
    { title: "Products", breadcrumbs: breadcrumb_items, actions: header_actions }
  end

  def table
    { items: @products, columns: table_columns, empty_state: empty_config }
  end

  # Extracted helper methods
  def breadcrumb_items
    [{ label: "Home", path: root_path }, { label: "Products" }]
  end

  def header_actions
    [{ label: "New", path: new_product_path, icon: "plus", style: :primary }]
  end

  def table_columns
    [
      { key: :name, label: "Name", type: :link },
      { key: :price, label: "Price", format: :currency }
    ]
  end

  def empty_config
    { icon: "box", title: "No products", message: "Create your first product" }
  end
end
```

--------------------------------

### Use Built-in Format Helpers

Use the provided helper methods for consistent formatting.

```ruby
# ShowBasePage helpers
action_format(path: edit_path, label: "Edit", icon: "edit", style: "primary")
statistic_format(label: "Total", value: 100, icon: "chart", color: "blue")
content_section_format(title: "Details", type: :info_grid, content: {...})

# FormBasePage helpers
field_format(name: :email, type: :email, label: "Email", required: true)
panel_format(title: "Basic Info", fields: [...])

# CustomBasePage helpers
widget_format(title: "Users", type: :counter, data: { value: 100 })
chart_format(title: "Revenue", type: :line, data: {...})
```

--------------------------------

### Separate Checkbox Panels

Always put checkbox and radio fields in separate panels from text inputs.

```ruby
# CORRECT
def panels
  [
    panel_format(
      title: "Details",
      fields: [
        field_format(name: :name, type: :text, label: "Name"),
        field_format(name: :email, type: :email, label: "Email")
      ]
    ),
    panel_format(
      title: "Settings",
      fields: [
        field_format(name: :active, type: :checkbox, label: "Active"),
        field_format(name: :newsletter, type: :checkbox, label: "Subscribe")
      ]
    )
  ]
end
```

--------------------------------

### Use Meaningful Component Names

Name components clearly to describe their purpose.

```ruby
# Clear component naming
def header_actions
  [{ label: "New", path: new_path }]
end

def table_columns
  [{ key: :name, label: "Name" }]
end

def filter_tabs
  [{ label: "All", path: index_path }]
end
```

--------------------------------

### Handle Empty States Gracefully

Always provide helpful empty states for lists and tables.

```ruby
def table
  {
    items: @products,
    columns: table_columns,
    empty_state: {
      icon: "inbox",
      title: "No products yet",
      message: "Get started by creating your first product",
      action: {
        label: "Create Product",
        path: new_product_path,
        style: :primary
      }
    }
  }
end
```

--------------------------------

### Use Consistent Styling

Define consistent style patterns across your application.

```ruby
# Define constants for reuse
module PageStyles
  BUTTON_STYLES = {
    primary: "primary",
    secondary: "secondary",
    danger: "danger"
  }.freeze

  COLORS = {
    success: "green",
    warning: "yellow",
    error: "red",
    info: "blue"
  }.freeze
end

# Use in pages
def header_actions
  [
    { label: "Save", style: PageStyles::BUTTON_STYLES[:primary] },
    { label: "Cancel", style: PageStyles::BUTTON_STYLES[:secondary] }
  ]
end
```

--------------------------------

### Run Compliance Checks Regularly

Add compliance checks to your CI pipeline.

```bash
# Run compliance analyzer
rake better_page:analyze

# In CI (exit with error if issues found)
STRICT=true rake better_page:analyze
```

--------------------------------

### Document Custom Components

Add comments explaining custom configurations.

```ruby
class Products::IndexPage < IndexBasePage
  private

  # Table columns with custom formatter for price
  # Price is displayed with currency symbol and 2 decimal places
  def table_columns
    [
      { key: :name, label: "Name", type: :link },
      { key: :price, label: "Price", format: :currency, precision: 2 }
    ]
  end

  # Statistics shown above the table
  # Only visible to admin users
  def statistics
    return [] unless @current_user.admin?

    [
      { label: "Total", value: @products.size },
      { label: "Revenue", value: format_currency(@stats[:revenue]) }
    ]
  end
end
```

--------------------------------

### Test Your Pages

Write tests for page output.

```ruby
require "test_helper"

class Products::IndexPageTest < ActiveSupport::TestCase
  test "returns correct header" do
    products = [Product.new(name: "Test")]
    page = Products::IndexPage.new(products, user: users(:admin)).index

    assert_equal "Products", page[:header][:title]
    assert_equal 1, page[:header][:actions].size
  end

  test "returns table with products" do
    products = [Product.new(name: "Test", price: 100)]
    page = Products::IndexPage.new(products, user: users(:admin)).index

    assert_equal 1, page[:table][:items].size
    assert_equal 3, page[:table][:columns].size
  end

  test "returns empty state when no products" do
    page = Products::IndexPage.new([], user: users(:admin)).index

    assert_equal "No products", page[:table][:empty_state][:title]
  end
end
```
