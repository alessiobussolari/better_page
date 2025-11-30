# Form Page

### Define a Form Page with Panels

Create a FormPage for new/edit forms. Header and panels are required.

```ruby
class Products::NewPage < BetterPage::FormBasePage
  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  private

  def header
    {
      title: "New Product",
      description: "Create a new product in your catalog"
    }
  end

  def panels
    [
      panel_format(
        title: "Basic Info",
        description: "Enter product details",
        fields: [
          field_format(name: :name, type: :text, label: "Name", required: true),
          field_format(name: :price, type: :number, label: "Price", required: true),
          field_format(name: :description, type: :textarea, label: "Description")
        ]
      )
    ]
  end
end
```

--------------------------------

### Form Page with Separate Checkbox Panel

Checkbox and radio fields MUST be in separate panels from text inputs.

```ruby
class Products::EditPage < BetterPage::FormBasePage
  def initialize(product, current_user)
    @product = product
    @current_user = current_user
  end

  private

  def header
    { title: "Edit #{@product.name}" }
  end

  def panels
    [
      # Text inputs panel
      panel_format(
        title: "Product Details",
        fields: [
          field_format(name: :name, type: :text, label: "Name", required: true),
          field_format(name: :price, type: :number, label: "Price"),
          field_format(name: :category, type: :select, label: "Category", options: category_options)
        ]
      ),
      # Checkbox panel - MUST be separate
      panel_format(
        title: "Settings",
        fields: [
          field_format(name: :active, type: :checkbox, label: "Active"),
          field_format(name: :featured, type: :checkbox, label: "Featured")
        ]
      )
    ]
  end
end
```

--------------------------------

### Form Page Helper Methods

Available helper methods for FormBasePage:

```ruby
# Build a field
field_format(
  name: :email,
  type: :email,        # :text, :email, :number, :textarea, :select, :checkbox, :radio
  label: "Email",
  required: true,
  placeholder: "Enter email",
  hint: "We'll never share your email"
)

# Build a panel
panel_format(
  title: "Basic Info",
  description: "Enter your details",
  fields: [...]
)
```

--------------------------------

### Form Page Footer Configuration

Customize form footer with primary and secondary actions.

```ruby
def footer
  {
    primary_action: {
      label: "Save Product",
      style: "primary"
    },
    secondary_actions: [
      { label: "Cancel", path: products_path, style: "secondary" }
    ]
  }
end
```
