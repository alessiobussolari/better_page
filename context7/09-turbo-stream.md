# Turbo Stream

### Update Multiple Components with Turbo Stream

Use `stream_<action>(*components)` to get multiple components for Turbo Stream updates.

```ruby
# In controller
def refresh
  @products = Product.filtered(params)
  components = Products::IndexPage.new(@products, current_user).stream_index(:table, :statistics)

  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: components.map { |c|
        turbo_stream.replace(c[:target], c[:klass].new(**c[:config]))
      }
    end
  end
end

# stream_index(:table, :statistics) returns:
# [
#   { component: :table, config: {...}, klass: TableComponent, target: "better_page_table" },
#   { component: :statistics, config: {...}, klass: StatsComponent, target: "better_page_statistics" }
# ]
```

--------------------------------

### Turbo Stream View Setup

Add target divs for Turbo Stream updates.

```erb
<%# app/views/products/index.html.erb %>

<div id="better_page_alerts">
  <%# Alerts rendered here %>
</div>

<div id="better_page_statistics">
  <%# Statistics rendered here %>
</div>

<div id="better_page_table">
  <%# Table rendered here %>
</div>

<div id="better_page_pagination">
  <%# Pagination rendered here %>
</div>
```

--------------------------------

### Dynamic Stream Methods by Page Type

Stream methods are generated based on the page's main action.

| Page Type | Main Action | Stream Method |
|-----------|-------------|---------------|
| IndexBasePage | `index` | `stream_index(*components)` |
| ShowBasePage | `show` | `stream_show(*components)` |
| FormBasePage | `form` | `stream_form(*components)` |
| CustomBasePage | `custom` | `stream_custom(*components)` |

--------------------------------

### Customize Default Stream Components

Override `stream_components` to define default components for stream methods.

```ruby
class Products::IndexPage < BetterPage::IndexBasePage
  def stream_components
    %i[alerts statistics table pagination]
  end
end

# Now stream_index without arguments returns these four
page.stream_index  # => alerts, statistics, table, pagination
```

--------------------------------

### Available Turbo Stream Actions

Use any Turbo Stream action with the returned components.

```ruby
components = page.stream_index(:table, :statistics)

components.each do |c|
  # Replace (default) - replaces entire element
  turbo_stream.replace(c[:target], c[:klass].new(**c[:config]))

  # Update - replaces content only, keeps element
  turbo_stream.update(c[:target], c[:klass].new(**c[:config]))

  # Append - adds after existing content
  turbo_stream.append(c[:target], c[:klass].new(**c[:config]))

  # Prepend - adds before existing content
  turbo_stream.prepend(c[:target], c[:klass].new(**c[:config]))

  # Remove - removes element
  turbo_stream.remove(c[:target])
end
```

--------------------------------

### Customize Stream Target

Override `stream_target` to customize DOM element IDs.

```ruby
class Products::IndexPage < BetterPage::IndexBasePage
  def stream_target(name)
    "products_#{name}"  # Returns "products_table" instead of "better_page_table"
  end
end
```
