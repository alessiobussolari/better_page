# Configuration

BetterPage uses a hybrid configuration system that combines global configuration with local customization.

### Configuration Levels

Components can be registered at three levels:

1. **Gem Defaults** - Built-in components registered by `BetterPage::DefaultComponents`
2. **Global Configuration** - User customizations in `config/initializers/better_page.rb`
3. **Local Classes** - Components in base page classes or individual pages

--------------------------------

### Global Configuration

Configure BetterPage in your initializer:

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  # Register a new component
  config.register_component :sidebar, default: { enabled: false } do
    optional(:enabled).filled(:bool)
    optional(:items).array(:hash)
  end

  # Map component to page types
  config.allow_components :index, :sidebar
  config.allow_components :show, :sidebar

  # Make component required for a page type
  config.require_components :index, :sidebar

  # Override a default component
  config.register_component :pagination, default: { enabled: true, per_page: 25 }
end
```

--------------------------------

### Configuration API

| Method | Description |
|--------|-------------|
| `register_component(name, options, &schema)` | Register a component with optional schema |
| `allow_components(page_type, *names)` | Map components to a page type |
| `require_components(page_type, *names)` | Mark components as required for a page type |
| `components_for(page_type)` | Get component names for a page type |
| `component(name)` | Get a component definition |
| `component_required?(page_type, name)` | Check if component is required |

--------------------------------

### Page Type DSL

Base page classes use `page_type` to inherit components from global configuration:

```ruby
# app/pages/index_base_page.rb
class IndexBasePage < ApplicationPage
  page_type :index  # Inherits components mapped to :index

  # Add local components
  register_component :quick_filters, default: []

  def index
    build_page
  end

  def view_component_class
    BetterPage::IndexViewComponent
  end
end
```

Available page types: `:index`, `:show`, `:form`, `:custom`

--------------------------------

### Default Components

BetterPage registers these components by default:

**Shared Components:**
- `header` - Page header with title, breadcrumbs, actions
- `alerts` - Alert messages (default: `[]`)
- `footer` - Footer section (default: `{ enabled: false }`)
- `statistics` - Statistic cards (default: `[]`)
- `overview` - Overview section (default: `{ enabled: false }`)

**Index Components:**
- `table` - Data table with columns and actions
- `tabs` - Tab navigation
- `search` - Search configuration
- `pagination` - Pagination settings
- `calendar` - Calendar view
- `modals` - Modal dialogs
- `split_view` - Split view layout

**Show Components:**
- `content_sections` - Content sections

**Form Components:**
- `panels` - Form panels with fields
- `errors` - Error display

**Custom Components:**
- `content` - Custom content

--------------------------------

### Sync Generator

Check for new components when upgrading BetterPage:

```bash
rails generate better_page:sync
```

This compares your configuration with gem defaults and reports:
- New components available from the gem
- Components you've customized

--------------------------------

### Example: Adding a Custom Component

```ruby
# 1. Register in initializer
# config/initializers/better_page.rb
BetterPage.configure do |config|
  config.register_component :activity_feed, default: { events: [], limit: 10 } do
    optional(:events).array(:hash)
    optional(:limit).filled(:integer)
  end
  config.allow_components :show, :activity_feed
end

# 2. Use in a page
# app/pages/admin/users/show_page.rb
class Admin::Users::ShowPage < ShowBasePage
  def activity_feed
    {
      events: @user.recent_activities.map { |a| format_activity(a) },
      limit: 20
    }
  end

  private

  def format_activity(activity)
    { type: activity.type, message: activity.message, at: activity.created_at }
  end
end
```
