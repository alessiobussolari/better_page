# Installation

### Install BetterPage Gem

Add BetterPage to your Rails application Gemfile.

```ruby
gem "better_page"
```

--------------------------------

### Run Bundle Install

Install the gem and its dependencies.

```bash
bundle install
```

--------------------------------

### Run Install Generator

Create the base ApplicationPage class in your application.

```bash
rails generate better_page:install
```

--------------------------------

### Generate Page Classes

Scaffold page classes for a resource with multiple actions.

```bash
rails generate better_page:page admin/users index show new edit
```

This creates:
- `app/pages/admin/users/index_page.rb`
- `app/pages/admin/users/show_page.rb`
- `app/pages/admin/users/new_page.rb`
- `app/pages/admin/users/edit_page.rb`
