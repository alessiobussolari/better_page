# Configuration

### Global Configuration

Configure BetterPage globally in an initializer.

```ruby
# config/initializers/better_page.rb
BetterPage.configure do |config|
  # Register global components
  config.register_component :alerts, default: []
  config.register_component :footer, default: { enabled: false }
end
```

--------------------------------

### Configuration API

Available methods in the configure block.

| Method | Description |
|--------|-------------|
| `register_component(name, options, &block)` | Register a component with optional schema |
| `allow_components(*names)` | Whitelist specific components |
| `require_components(*names)` | Mark components as required |

--------------------------------

### page_type DSL

Declare the page type in base classes to inherit default components.

```ruby
# app/pages/index_base_page.rb
class IndexBasePage < ApplicationPage
  page_type :index
end
```

Available types: `:index`, `:show`, `:form`, `:custom`

--------------------------------

### Default Components by Type

Components registered by the gem for each page type.

**Index Pages:**
- `header` (required) - Page header with title, breadcrumbs, actions
- `table` (required) - Table with items, columns, actions
- `alerts` - Flash messages and notifications
- `statistics` - Stat cards above the table
- `pagination` - Page navigation
- `search` - Search configuration
- `tabs` - Tab navigation

**Show Pages:**
- `header` (required) - Page header with title, breadcrumbs, actions
- `alerts` - Flash messages and notifications
- `statistics` - Stat cards for key metrics
- `content_sections` - Detail sections (info grid, text)

**Form Pages:**
- `header` (required) - Page header with title, description
- `panels` (required) - Form panels with fields
- `alerts` - Flash messages and notifications
- `footer` - Submit and cancel actions

**Custom Pages:**
- `header` - Page header
- `content` (required) - Custom content with widgets/charts
- `alerts` - Flash messages and notifications

--------------------------------

### Adding Custom Global Components

Add components that apply to all page types.

```ruby
BetterPage.configure do |config|
  config.register_component :sidebar, default: { enabled: false }
  config.register_component :help_panel, default: nil
end
```

--------------------------------

### Sync Generator

Check for new default components when upgrading BetterPage.

```bash
rails generate better_page:sync
```

This shows:
- New components added in the gem
- Components that may need updating
- Suggestions for your base classes
