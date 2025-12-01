# Quick Start Guide

Get started with BetterPage in 5 minutes.

### Install the Gem

```ruby
# Gemfile
gem "better_page"
```

```bash
bundle install
rails g better_page:install
```

This creates:
- `app/pages/application_page.rb` - Base page class
- `app/pages/index_base_page.rb` - Base for index pages
- `app/pages/show_base_page.rb` - Base for show pages
- `app/pages/form_base_page.rb` - Base for form pages
- `app/pages/custom_base_page.rb` - Base for custom pages
- `config/initializers/better_page.rb` - Configuration file

--------------------------------

### Generate Your First Page

```bash
rails g better_page:page Admin::Products index show new edit
```

This creates:
- `app/pages/admin/products/index_page.rb`
- `app/pages/admin/products/show_page.rb`
- `app/pages/admin/products/new_page.rb`
- `app/pages/admin/products/edit_page.rb`

--------------------------------

### Basic Index Page

```ruby
# app/pages/admin/products/index_page.rb
module Admin
  module Products
    class IndexPage < IndexBasePage
      def initialize(products, metadata = {})
        @products = products
        @user = metadata[:user]
        super(products, metadata)
      end

      private

      def header
        {
          title: "Products",
          breadcrumbs: [
            { label: "Home", path: "/" },
            { label: "Products" }
          ],
          actions: [
            { label: "New Product", path: "/products/new", icon: "plus", style: :primary }
          ]
        }
      end

      def table
        {
          items: @products,
          columns: [
            { key: :name, label: "Name", type: :link },
            { key: :price, label: "Price", format: :currency },
            { key: :active, label: "Status", type: :boolean }
          ],
          empty_state: {
            icon: "box",
            title: "No products yet",
            message: "Create your first product to get started"
          }
        }
      end
    end
  end
end
```

--------------------------------

### Use in Controller

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < ApplicationController
  def index
    products = Product.all
    @page = Admin::Products::IndexPage.new(products, user: current_user).index
  end
end
```

--------------------------------

### Render in View

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render "shared/page", page: @page %>
```

Or access data directly:

```erb
<h1><%= @page[:header][:title] %></h1>

<table>
  <thead>
    <tr>
      <% @page[:table][:columns].each do |column| %>
        <th><%= column[:label] %></th>
      <% end %>
    </tr>
  </thead>
  <tbody>
    <% @page[:table][:items].each do |item| %>
      <tr>
        <% @page[:table][:columns].each do |column| %>
          <td><%= item.send(column[:key]) %></td>
        <% end %>
      </tr>
    <% end %>
  </tbody>
</table>
```

--------------------------------

### Verify Compliance

```bash
rake better_page:analyze
```

This ensures your pages follow the architecture rules:
- No database queries in pages
- No business logic
- Data passed via constructor
