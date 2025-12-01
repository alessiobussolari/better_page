# Show Page

### Define a Show Page with Header

Create a ShowPage for displaying record details with header and content sections.

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
      breadcrumbs: [
        { label: "Products", path: products_path },
        { label: @product.name }
      ],
      actions: [
        action_format(path: edit_product_path(@product), label: "Edit", icon: "edit", style: "primary")
      ]
    }
  end
end
```

--------------------------------

### Show Page with Content Sections

Add content sections using helper methods for info grids and statistics.

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

  def statistics
    [
      statistic_format(label: "Price", value: @product.price, icon: "dollar", color: "green"),
      statistic_format(label: "Stock", value: @product.stock, icon: "box", color: "blue")
    ]
  end

  def content_sections
    [
      content_section_format(
        title: "Details",
        icon: "info",
        color: "blue",
        type: :info_grid,
        content: {
          "Category" => @product.category,
          "SKU" => @product.sku,
          "Created" => @product.created_at.strftime("%B %d, %Y")
        }
      ),
      content_section_format(
        title: "Description",
        icon: "text",
        type: :text,
        content: @product.description
      )
    ]
  end
end
```

--------------------------------

### Show Page Helper Methods

Available helper methods for ShowBasePage:

```ruby
# Format an action button
action_format(path: edit_path, label: "Edit", icon: "edit", style: "primary")

# Format a statistic card
statistic_format(label: "Total", value: 100, icon: "chart", color: "blue")

# Format a content section
content_section_format(
  title: "Details",
  icon: "info",
  color: "blue",
  type: :info_grid,  # or :text
  content: { "Name" => "Value" }
)

# Convert hash to info grid format
info_grid_content_format({ "Name" => "John", "Email" => "john@example.com" })
# => [{ name: "Name", value: "John" }, { name: "Email", value: "john@example.com" }]
```
