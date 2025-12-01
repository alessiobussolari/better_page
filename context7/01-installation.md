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

Create the page infrastructure in your application.

```bash
rails generate better_page:install
```

This creates:
- `config/initializers/better_page.rb` - Global configuration
- `app/pages/application_page.rb` - Base class for all pages
- `app/pages/index_base_page.rb` - Base class for list pages
- `app/pages/show_base_page.rb` - Base class for detail pages
- `app/pages/form_base_page.rb` - Base class for form pages
- `app/pages/custom_base_page.rb` - Base class for custom pages
- `app/components/better_page/application_view_component.rb` - Base ViewComponent (includes `Turbo::FramesHelper`)
- `app/components/better_page/` - ViewComponents for rendering pages

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

--------------------------------

### Sync Generator

Check for gem updates and sync local base classes.

```bash
rails generate better_page:sync
```

Use this when upgrading BetterPage to get new default components.
