# Building a Show Page

A complete guide to building detail pages with content sections.

### Basic Show Page Structure

```ruby
class Products::ShowPage < ShowBasePage
  def initialize(product, metadata = {})
    @product = product
    @user = metadata[:user]
    super(product, metadata)
  end

  private

  def header
    { title: @product.name }
  end
end
```

--------------------------------

### Adding Header with Actions

```ruby
def header
  {
    title: @product.name,
    breadcrumbs: [
      { label: "Products", path: products_path },
      { label: @product.name }
    ],
    actions: [
      action_format(path: edit_product_path(@product), label: "Edit", icon: "edit", style: "secondary"),
      action_format(path: product_path(@product), label: "Delete", icon: "trash", style: "danger", method: :delete, confirm: "Delete this product?")
    ]
  }
end
```

--------------------------------

### Using action_format Helper

Build action buttons with the helper method.

```ruby
action_format(
  path: edit_product_path(@product),
  label: "Edit",
  icon: "edit",
  style: "primary"  # primary, secondary, danger, warning
)
```

--------------------------------

### Adding Statistics

```ruby
def statistics
  [
    statistic_format(label: "Price", value: format_currency(@product.price), icon: "dollar", color: "green"),
    statistic_format(label: "Stock", value: @product.stock, icon: "box", color: "blue"),
    statistic_format(label: "Orders", value: @product.orders_count, icon: "shopping-cart", color: "purple"),
    statistic_format(label: "Rating", value: "#{@product.rating}/5", icon: "star", color: "yellow")
  ]
end
```

--------------------------------

### Using statistic_format Helper

Build statistic cards with the helper method.

```ruby
statistic_format(
  label: "Total Sales",
  value: 1234,
  icon: "chart",
  color: "blue"  # blue, green, red, yellow, purple
)
```

--------------------------------

### Adding Content Sections - Info Grid

```ruby
def content_sections
  [
    content_section_format(
      title: "Product Details",
      icon: "info",
      color: "blue",
      type: :info_grid,
      content: {
        "SKU" => @product.sku,
        "Category" => @product.category,
        "Brand" => @product.brand,
        "Weight" => "#{@product.weight} kg",
        "Dimensions" => @product.dimensions,
        "Created" => @product.created_at.strftime("%B %d, %Y")
      }
    )
  ]
end
```

--------------------------------

### Adding Content Sections - Text

```ruby
def content_sections
  [
    content_section_format(
      title: "Description",
      icon: "text",
      color: "gray",
      type: :text,
      content: @product.description
    )
  ]
end
```

--------------------------------

### Using content_section_format Helper

Build content sections with the helper method.

```ruby
content_section_format(
  title: "Section Title",
  icon: "info",          # icon name
  color: "blue",         # blue, green, red, gray
  type: :info_grid,      # :info_grid or :text
  content: { "Key" => "Value" }  # Hash for info_grid, String for text
)
```

--------------------------------

### Using info_grid_content_format Helper

Convert hash to info grid array format.

```ruby
info_grid_content_format({ "Name" => "John", "Email" => "john@example.com" })
# => [{ name: "Name", value: "John" }, { name: "Email", value: "john@example.com" }]
```

--------------------------------

### Adding Multiple Content Sections

```ruby
def content_sections
  [
    content_section_format(
      title: "Product Details",
      icon: "info",
      color: "blue",
      type: :info_grid,
      content: product_details_content
    ),
    content_section_format(
      title: "Description",
      icon: "text",
      color: "gray",
      type: :text,
      content: @product.description
    ),
    content_section_format(
      title: "Shipping Information",
      icon: "truck",
      color: "green",
      type: :info_grid,
      content: shipping_content
    )
  ]
end

def product_details_content
  {
    "SKU" => @product.sku,
    "Category" => @product.category,
    "Brand" => @product.brand
  }
end

def shipping_content
  {
    "Weight" => "#{@product.weight} kg",
    "Dimensions" => @product.dimensions,
    "Ships From" => @product.warehouse
  }
end
```

--------------------------------

### Complete Show Page Example

```ruby
class Products::ShowPage < ShowBasePage
  def initialize(product, metadata = {})
    @product = product
    @user = metadata[:user]
    super(product, metadata)
  end

  private

  def header
    {
      title: @product.name,
      breadcrumbs: [{ label: "Products", path: products_path }, { label: @product.name }],
      actions: header_actions
    }
  end

  def statistics
    [
      statistic_format(label: "Price", value: format_currency(@product.price), icon: "dollar", color: "green"),
      statistic_format(label: "Stock", value: @product.stock, icon: "box", color: "blue"),
      statistic_format(label: "Orders", value: @product.orders_count, icon: "cart", color: "purple")
    ]
  end

  def content_sections
    [
      content_section_format(
        title: "Details",
        icon: "info",
        color: "blue",
        type: :info_grid,
        content: { "SKU" => @product.sku, "Category" => @product.category }
      ),
      content_section_format(
        title: "Description",
        icon: "text",
        color: "gray",
        type: :text,
        content: @product.description
      )
    ]
  end

  def header_actions
    [
      action_format(path: edit_product_path(@product), label: "Edit", icon: "edit", style: "secondary"),
      action_format(path: product_path(@product), label: "Delete", icon: "trash", style: "danger", method: :delete)
    ]
  end

  def format_currency(amount)
    "$#{amount.to_f.round(2)}"
  end
end
```
