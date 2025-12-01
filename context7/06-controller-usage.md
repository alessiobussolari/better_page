# Controller Usage

### Use Page in Controller

Instantiate the page and call the main action method. Page returns Hash, controller handles rendering.

```ruby
class ProductsController < ApplicationController
  def index
    @products = Product.all.order(:name)
    @page = Products::IndexPage.new(@products, user: current_user).index
  end

  def show
    @product = Product.find(params[:id])
    @page = Products::ShowPage.new(@product, user: current_user).show
  end

  def new
    @product = Product.new
    @page = Products::NewPage.new(@product, user: current_user).form
  end

  def edit
    @product = Product.find(params[:id])
    @page = Products::EditPage.new(@product, user: current_user).form
  end
end
```

--------------------------------

### Access Page Data in Views

Use the @page hash to render UI components.

```erb
<%# app/views/products/index.html.erb %>

<h1><%= @page[:header][:title] %></h1>

<% @page[:header][:breadcrumbs]&.each do |crumb| %>
  <a href="<%= crumb[:path] %>"><%= crumb[:label] %></a>
<% end %>

<% @page[:statistics]&.each do |stat| %>
  <div class="stat">
    <span class="label"><%= stat[:label] %></span>
    <span class="value"><%= stat[:value] %></span>
  </div>
<% end %>

<table>
  <thead>
    <tr>
      <% @page[:table][:columns].each do |col| %>
        <th><%= col[:label] %></th>
      <% end %>
    </tr>
  </thead>
  <tbody>
    <% @page[:table][:items].each do |item| %>
      <tr>
        <% @page[:table][:columns].each do |col| %>
          <td><%= item.send(col[:key]) %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>
```

--------------------------------

### Page Returns Hash Structure

Each page action returns a complete Hash with all component configurations.

```ruby
# Products::IndexPage.new(@products, user: current_user).index returns:
{
  header: {
    title: "Products",
    breadcrumbs: [...],
    actions: [...]
  },
  table: {
    items: [...],
    columns: [...],
    empty_state: {...}
  },
  statistics: [...],
  pagination: { enabled: false },
  alerts: [],
  # ... other optional components with defaults
}
```
