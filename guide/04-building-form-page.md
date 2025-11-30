# Building Form Pages

A complete guide to building new and edit form pages.

### Basic Form Page Structure

```ruby
class Products::NewPage < BetterPage::FormBasePage
  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  private

  def build_form_header
    { title: "New Product" }
  end

  def build_form_panels
    [
      panel_format(title: "Basic Info", fields: basic_fields)
    ]
  end
end
```

--------------------------------

### Adding Header with Description

```ruby
def build_form_header
  {
    title: "New Product",
    description: "Create a new product in your catalog",
    breadcrumbs: [
      { label: "Products", path: products_path },
      { label: "New" }
    ]
  }
end
```

--------------------------------

### Using field_format Helper

Build form fields with the helper method.

```ruby
field_format(
  name: :email,
  type: :email,           # :text, :email, :password, :number, :textarea, :select, :checkbox, :radio
  label: "Email Address",
  required: true,
  placeholder: "Enter email",
  hint: "We'll never share your email"
)
```

--------------------------------

### Field Types

```ruby
# Text input
field_format(name: :name, type: :text, label: "Name", required: true)

# Email input
field_format(name: :email, type: :email, label: "Email")

# Password input
field_format(name: :password, type: :password, label: "Password")

# Number input
field_format(name: :price, type: :number, label: "Price", min: 0, step: 0.01)

# Textarea
field_format(name: :description, type: :textarea, label: "Description", rows: 5)

# Select dropdown
field_format(name: :category, type: :select, label: "Category", options: category_options)

# Checkbox
field_format(name: :active, type: :checkbox, label: "Active")

# Radio buttons
field_format(name: :status, type: :radio, label: "Status", options: status_options)
```

--------------------------------

### Using panel_format Helper

Build form panels with the helper method.

```ruby
panel_format(
  title: "Basic Information",
  description: "Enter the product details",
  fields: [
    field_format(name: :name, type: :text, label: "Name", required: true),
    field_format(name: :price, type: :number, label: "Price", required: true)
  ]
)
```

--------------------------------

### Important: Separate Checkbox Panels

Checkbox and radio fields MUST be in separate panels from text inputs.

```ruby
def build_form_panels
  [
    # Text inputs panel
    panel_format(
      title: "Product Details",
      fields: [
        field_format(name: :name, type: :text, label: "Name", required: true),
        field_format(name: :price, type: :number, label: "Price"),
        field_format(name: :category, type: :select, label: "Category", options: categories)
      ]
    ),
    # Checkbox panel - MUST be separate
    panel_format(
      title: "Settings",
      fields: [
        field_format(name: :active, type: :checkbox, label: "Active"),
        field_format(name: :featured, type: :checkbox, label: "Featured on Homepage")
      ]
    )
  ]
end
```

--------------------------------

### Select Field with Options

```ruby
def build_form_panels
  [
    panel_format(
      title: "Details",
      fields: [
        field_format(
          name: :category_id,
          type: :select,
          label: "Category",
          options: category_options,
          include_blank: "Select a category"
        )
      ]
    )
  ]
end

def category_options
  [
    { value: 1, label: "Electronics" },
    { value: 2, label: "Clothing" },
    { value: 3, label: "Books" }
  ]
end
```

--------------------------------

### Configuring Footer

```ruby
def footer
  {
    primary_action: {
      label: "Save Product",
      style: "primary"
    },
    secondary_actions: [
      { label: "Cancel", path: products_path, style: "secondary" },
      { label: "Save as Draft", action: :draft, style: "outline" }
    ]
  }
end
```

--------------------------------

### Edit Page Example

```ruby
class Products::EditPage < BetterPage::FormBasePage
  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  private

  def build_form_header
    {
      title: "Edit #{@product.name}",
      breadcrumbs: [
        { label: "Products", path: products_path },
        { label: @product.name, path: product_path(@product) },
        { label: "Edit" }
      ]
    }
  end

  def build_form_panels
    [
      panel_format(title: "Product Details", fields: detail_fields),
      panel_format(title: "Pricing", fields: pricing_fields),
      panel_format(title: "Settings", fields: settings_fields)
    ]
  end

  def detail_fields
    [
      field_format(name: :name, type: :text, label: "Name", required: true, value: @product.name),
      field_format(name: :description, type: :textarea, label: "Description", value: @product.description)
    ]
  end

  def pricing_fields
    [
      field_format(name: :price, type: :number, label: "Price", value: @product.price, min: 0),
      field_format(name: :compare_price, type: :number, label: "Compare at Price", value: @product.compare_price)
    ]
  end

  def settings_fields
    [
      field_format(name: :active, type: :checkbox, label: "Active", checked: @product.active?),
      field_format(name: :featured, type: :checkbox, label: "Featured", checked: @product.featured?)
    ]
  end
end
```

--------------------------------

### Complete New Page Example

```ruby
class Products::NewPage < BetterPage::FormBasePage
  def initialize(product, current_user, categories:)
    @product = product
    @current_user = current_user
    @categories = categories
  end

  private

  def build_form_header
    {
      title: "New Product",
      description: "Add a new product to your catalog",
      breadcrumbs: [{ label: "Products", path: products_path }, { label: "New" }]
    }
  end

  def build_form_panels
    [
      panel_format(
        title: "Basic Information",
        description: "Enter the product details",
        fields: [
          field_format(name: :name, type: :text, label: "Product Name", required: true),
          field_format(name: :sku, type: :text, label: "SKU"),
          field_format(name: :category_id, type: :select, label: "Category", options: category_options),
          field_format(name: :description, type: :textarea, label: "Description", rows: 4)
        ]
      ),
      panel_format(
        title: "Pricing & Inventory",
        fields: [
          field_format(name: :price, type: :number, label: "Price", required: true, min: 0, step: 0.01),
          field_format(name: :stock, type: :number, label: "Stock Quantity", min: 0)
        ]
      ),
      panel_format(
        title: "Settings",
        fields: [
          field_format(name: :active, type: :checkbox, label: "Active"),
          field_format(name: :featured, type: :checkbox, label: "Featured on Homepage")
        ]
      )
    ]
  end

  def footer
    {
      primary_action: { label: "Create Product", style: "primary" },
      secondary_actions: [{ label: "Cancel", path: products_path, style: "secondary" }]
    }
  end

  def category_options
    @categories.map { |c| { value: c.id, label: c.name } }
  end
end
```
