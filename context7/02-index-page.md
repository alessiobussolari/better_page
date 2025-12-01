# Index Page

### Define an Index Page with Header and Table

Create an IndexPage that returns Hash configurations for header and table components. Data is passed via constructor.

```ruby
class Products::IndexPage < IndexBasePage
  def initialize(products, metadata = {})
    @products = products
    @user = metadata[:user]
    super(products, metadata)
  end

  private

  def header
    {
      title: "Products",
      breadcrumbs: [{ label: "Home", path: root_path }],
      actions: [{ label: "New", path: new_product_path, style: :primary }]
    }
  end

  def table
    {
      items: @products,
      columns: [
        { key: :name, label: "Name", type: :link },
        { key: :price, label: "Price", format: :currency }
      ],
      empty_state: {
        icon: "box",
        title: "No products",
        message: "Create your first product"
      }
    }
  end
end
```

--------------------------------

### Index Page with Statistics

Add statistics cards above the table.

```ruby
class Products::IndexPage < IndexBasePage
  def initialize(products, metadata = {})
    @products = products
    @user = metadata[:user]
    super(products, metadata)
  end

  private

  def header
    { title: "Products" }
  end

  def table
    { items: @products, columns: table_columns }
  end

  def statistics
    [
      { label: "Total", value: @products.size, icon: "box" },
      { label: "Active", value: @products.count(&:active?), icon: "check" }
    ]
  end

  def pagination
    {
      enabled: true,
      page: 1,
      total_pages: 10,
      per_page: 25
    }
  end
end
```

--------------------------------

### Index Page Required Components

IndexBasePage requires these components:

| Component | Required | Default |
|-----------|----------|---------|
| `header` | Yes | - |
| `table` | Yes | - |
| `alerts` | No | `[]` |
| `statistics` | No | `[]` |
| `pagination` | No | `{ enabled: false }` |
| `search` | No | `{ enabled: false }` |
| `tabs` | No | `{ enabled: false }` |
