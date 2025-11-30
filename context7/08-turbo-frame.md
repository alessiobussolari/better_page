# Turbo Frame

### Lazy Load Component with Turbo Frame

Use `frame_<action>(:component)` to get a single component for Turbo Frame lazy loading.

```ruby
# In controller
def table
  @products = Product.all
  component = Products::IndexPage.new(@products, current_user).frame_index(:table)

  render component[:klass].new(**component[:config])
end

# frame_index(:table) returns:
# {
#   component: :table,
#   config: { items: [...], columns: [...] },
#   klass: TableComponent,
#   target: "better_page_table"
# }
```

--------------------------------

### Turbo Frame View Setup

Add turbo-frame tag with lazy loading in your view.

```erb
<%# app/views/products/index.html.erb %>

<h1><%= @page[:header][:title] %></h1>

<%# Lazy load table via Turbo Frame %>
<turbo-frame id="better_page_table" src="<%= table_products_path %>" loading="lazy">
  <p>Loading products...</p>
</turbo-frame>
```

--------------------------------

### Dynamic Frame Methods by Page Type

Frame methods are generated based on the page's main action.

| Page Type | Main Action | Frame Method |
|-----------|-------------|--------------|
| IndexBasePage | `index` | `frame_index(:component)` |
| ShowBasePage | `show` | `frame_show(:component)` |
| FormBasePage | `form` | `frame_form(:component)` |
| CustomBasePage | `custom` | `frame_custom(:component)` |

--------------------------------

### Custom Frame Method for Custom Action

If you define a custom action, frame methods work automatically.

```ruby
class Reports::DailyPage < BetterPage::CustomBasePage
  register_component :chart, default: {}

  def daily
    build_page
  end

  def chart
    { type: :line, data: @data }
  end
end

# Usage
page = Reports::DailyPage.new(@data)
page.frame_daily(:chart)  # Works automatically
```

--------------------------------

### Customize Frame Target

Override `frame_target` to customize DOM element IDs.

```ruby
class Products::IndexPage < BetterPage::IndexBasePage
  def frame_target(name)
    "products_#{name}"  # Returns "products_table" instead of "better_page_table"
  end
end
```
