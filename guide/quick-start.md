# Quick Start Guide

Get BetterPage running in your Rails application in 5 minutes.

## Step 1: Install the Gem

Add to your Gemfile:

```ruby
gem "better_page"
```

Run:

```bash
bundle install
```

## Step 2: Run the Install Generator

```bash
rails generate better_page:install
```

This creates `app/pages/application_page.rb`.

## Step 3: Generate Your First Page

```bash
rails generate better_page:page admin/products index
```

This creates `app/pages/admin/products/index_page.rb`:

```ruby
module Admin
  module Products
    class IndexPage < BetterPage::IndexBasePage
      def initialize(products, user, params = {})
        @products = products
        @user = user
        @params = params
      end

      private

      def header
        {
          title: "Products",
          breadcrumbs: breadcrumbs_config,
          actions: []
        }
      end

      def table
        {
          items: @products,
          columns: [],
          empty_state: {
            icon: "inbox",
            title: "No products found",
            message: "There are no products to display."
          }
        }
      end
    end
  end
end
```

## Step 4: Configure Your Page

Edit the page to add columns and customize:

```ruby
def header
  {
    title: "Products",
    breadcrumbs: [
      { label: "Admin", path: admin_root_path },
      { label: "Products", path: admin_products_path }
    ],
    actions: [
      { label: "New Product", path: new_admin_product_path, icon: "plus", style: "primary" }
    ]
  }
end

def table
  {
    items: @products,
    columns: [
      { key: :name, label: "Name", type: :link, path: ->(item) { admin_product_path(item) } },
      { key: :price, label: "Price", type: :currency },
      { key: :status, label: "Status", type: :badge }
    ],
    actions: table_actions,
    empty_state: {
      icon: "box",
      title: "No products",
      message: "Create your first product to get started",
      action: { label: "New Product", path: new_admin_product_path }
    }
  }
end

def table_actions
  lambda { |item|
    [
      { label: "View", path: admin_product_path(item), icon: "eye" },
      { label: "Edit", path: edit_admin_product_path(item), icon: "edit" }
    ]
  }
end
```

## Step 5: Use in Controller

```ruby
class Admin::ProductsController < ApplicationController
  def index
    products = Product.all.order(:name)
    @page = Admin::Products::IndexPage.new(products, current_user, params).index
  end
end
```

## Step 6: Render in View

```erb
<%# app/views/admin/products/index.html.erb %>

<h1><%= @page[:header][:title] %></h1>

<%# Render breadcrumbs %>
<nav>
  <% @page[:header][:breadcrumbs].each do |crumb| %>
    <%= link_to crumb[:label], crumb[:path] %>
  <% end %>
</nav>

<%# Render actions %>
<% @page[:header][:actions].each do |action| %>
  <%= link_to action[:label], action[:path], class: action[:style] %>
<% end %>

<%# Render table %>
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

## Next Steps

- [Building an Index Page](building-index-page.md) - Full index page guide
- [Building a Show Page](building-show-page.md) - Detail pages
- [Building a Form Page](building-form-page.md) - Forms
- [Best Practices](best-practices.md) - Patterns and tips
