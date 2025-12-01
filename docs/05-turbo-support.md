# Turbo Support

BetterPage provides built-in support for Turbo Frames and Turbo Streams.

### Turbo Helpers in ViewComponents

All BetterPage ViewComponents inherit from `ApplicationViewComponent`, which includes `Turbo::FramesHelper`. This means you have access to Turbo helpers like `turbo_frame_tag` directly in your component templates.

```ruby
# app/components/better_page/application_view_component.rb
module BetterPage
  class ApplicationViewComponent < ViewComponent::Base
    include Turbo::FramesHelper
  end
end
```

This allows you to use Turbo helpers in any component template:

```erb
<%# In any component .html.erb template %>
<%= turbo_frame_tag "my_frame" do %>
  <!-- Content -->
<% end %>
```

--------------------------------

### Overview

| Method Type | Use Case | Returns |
|-------------|----------|---------|
| `frame_*` | Lazy loading, navigation | Single Hash |
| `stream_*` | Real-time updates, form responses | Array of Hashes |

--------------------------------

### Turbo Frame - Lazy Load Component

Use `frame_<action>(:component)` to get a single component for Turbo Frame.

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

```erb
<turbo-frame id="better_page_table" src="<%= table_products_path %>" loading="lazy">
  <p>Loading products...</p>
</turbo-frame>
```

--------------------------------

### Turbo Stream - Update Multiple Components

Use `stream_<action>(*components)` to get multiple components for Turbo Stream.

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

```erb
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

### Dynamic Methods by Page Type

Methods are generated based on the page's main action.

| Page Type | Main Action | Frame Method | Stream Method |
|-----------|-------------|--------------|---------------|
| IndexBasePage | `index` | `frame_index(:component)` | `stream_index(*components)` |
| ShowBasePage | `show` | `frame_show(:component)` | `stream_show(*components)` |
| FormBasePage | `form` | `frame_form(:component)` | `stream_form(*components)` |
| CustomBasePage | `custom` | `frame_custom(:component)` | `stream_custom(*components)` |

--------------------------------

### Custom Action Methods

If you define a custom action, turbo methods work automatically.

```ruby
class Reports::DailyPage < CustomBasePage
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
page.frame_daily(:chart)           # Single component
page.stream_daily(:chart, :summary) # Multiple components
```

--------------------------------

### Customize Default Stream Components

Override `stream_components` to define defaults.

```ruby
class Products::IndexPage < IndexBasePage
  def stream_components
    %i[alerts statistics table pagination]
  end
end

# Now stream_index without arguments returns these four
page.stream_index  # => alerts, statistics, table, pagination
```

--------------------------------

### Customize Frame Target

Override `frame_target` to customize DOM element IDs.

```ruby
def frame_target(name)
  "products_#{name}"  # "products_table" instead of "better_page_table"
end
```

--------------------------------

### Customize Stream Target

Override `stream_target` to customize DOM element IDs.

```ruby
def stream_target(name)
  "products_#{name}"
end
```

--------------------------------

### Available Turbo Stream Actions

```ruby
components.each do |c|
  # Replace - replaces entire element
  turbo_stream.replace(c[:target], c[:klass].new(**c[:config]))

  # Update - replaces content only
  turbo_stream.update(c[:target], c[:klass].new(**c[:config]))

  # Append - adds after existing content
  turbo_stream.append(c[:target], c[:klass].new(**c[:config]))

  # Prepend - adds before existing content
  turbo_stream.prepend(c[:target], c[:klass].new(**c[:config]))

  # Remove - removes element
  turbo_stream.remove(c[:target])
end
```
