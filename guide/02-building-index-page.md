# Building an Index Page

A complete guide to building feature-rich index pages.

### Basic Index Page Structure

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
end
```

--------------------------------

### Adding Breadcrumbs

```ruby
def header
  {
    title: "Products",
    breadcrumbs: [
      { label: "Home", path: root_path },
      { label: "Admin", path: admin_root_path },
      { label: "Products" }
    ]
  }
end
```

--------------------------------

### Adding Header Actions

```ruby
def header
  {
    title: "Products",
    actions: [
      { label: "Export", path: export_products_path, icon: "download", style: :secondary },
      { label: "New Product", path: new_product_path, icon: "plus", style: :primary }
    ]
  }
end
```

--------------------------------

### Defining Table Columns

```ruby
def table
  {
    items: @products,
    columns: [
      { key: :name, label: "Name", type: :link, path: ->(p) { product_path(p) } },
      { key: :category, label: "Category", type: :badge },
      { key: :price, label: "Price", format: :currency },
      { key: :stock, label: "Stock", type: :number },
      { key: :active, label: "Status", type: :boolean },
      { key: :created_at, label: "Created", format: :date }
    ]
  }
end
```

--------------------------------

### Adding Row Actions

```ruby
def table
  {
    items: @products,
    columns: table_columns,
    actions: ->(product) {
      [
        { label: "Edit", path: edit_product_path(product), icon: "edit" },
        { label: "Delete", path: product_path(product), method: :delete, icon: "trash", confirm: "Are you sure?" }
      ]
    }
  }
end
```

--------------------------------

### Configuring Empty State

```ruby
def table
  {
    items: @products,
    columns: table_columns,
    empty_state: {
      icon: "box",
      title: "No products yet",
      message: "Create your first product to get started",
      action: {
        label: "New Product",
        path: new_product_path,
        style: :primary
      }
    }
  }
end
```

--------------------------------

### Adding Statistics

```ruby
def statistics
  [
    { label: "Total Products", value: @products.size, icon: "box", color: "blue" },
    { label: "Active", value: @products.count(&:active?), icon: "check", color: "green" },
    { label: "Out of Stock", value: @products.count { |p| p.stock.zero? }, icon: "alert", color: "red" },
    { label: "Total Value", value: format_currency(@products.sum(&:price)), icon: "dollar", color: "purple" }
  ]
end
```

--------------------------------

### Adding Pagination

```ruby
def pagination
  {
    enabled: true,
    page: @products.current_page,
    total_pages: @products.total_pages,
    total_count: @products.total_count,
    per_page: @products.limit_value
  }
end
```

--------------------------------

### Adding Search

```ruby
def search
  {
    enabled: true,
    placeholder: "Search products...",
    fields: [:name, :category, :sku]
  }
end
```

--------------------------------

### Adding Tabs

```ruby
def tabs
  {
    enabled: true,
    items: [
      { label: "All", path: products_path, active: @filter == :all },
      { label: "Active", path: products_path(filter: :active), active: @filter == :active },
      { label: "Inactive", path: products_path(filter: :inactive), active: @filter == :inactive }
    ]
  }
end
```

--------------------------------

### Complete Index Page Example

```ruby
class Products::IndexPage < IndexBasePage
  def initialize(products, metadata = {})
    @products = products
    @user = metadata[:user]
    @filter = metadata[:filter] || :all
    super(products, metadata)
  end

  private

  def header
    {
      title: "Products",
      breadcrumbs: [{ label: "Home", path: root_path }, { label: "Products" }],
      actions: header_actions
    }
  end

  def table
    {
      items: @products,
      columns: table_columns,
      actions: row_actions,
      empty_state: empty_config
    }
  end

  def statistics
    [
      { label: "Total", value: @products.size, icon: "box" },
      { label: "Active", value: @products.count(&:active?), icon: "check", color: "green" }
    ]
  end

  def pagination
    { enabled: true, page: @products.current_page, total_pages: @products.total_pages }
  end

  def tabs
    {
      enabled: true,
      items: [
        { label: "All", path: products_path, active: @filter == :all },
        { label: "Active", path: products_path(filter: :active), active: @filter == :active }
      ]
    }
  end

  # Private helper methods
  def header_actions
    [{ label: "New Product", path: new_product_path, icon: "plus", style: :primary }]
  end

  def table_columns
    [
      { key: :name, label: "Name", type: :link },
      { key: :price, label: "Price", format: :currency },
      { key: :stock, label: "Stock" }
    ]
  end

  def row_actions
    ->(p) { [{ label: "Edit", path: edit_product_path(p), icon: "edit" }] }
  end

  def empty_config
    { icon: "box", title: "No products", message: "Create your first product" }
  end
end
```
