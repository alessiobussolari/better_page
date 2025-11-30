# better-page-stimulus

Stimulus controllers for [BetterPage](https://github.com/alessiobussolari/better_page) Rails gem.

## Installation

### Option 1: npm/yarn

```bash
npm install better-page-stimulus
# or
yarn add better-page-stimulus
```

Then in your `app/javascript/controllers/index.js`:

```javascript
import { Application } from "@hotwired/stimulus"
import { registerBetterPageControllers } from "better-page-stimulus"

const application = Application.start()
registerBetterPageControllers(application)
```

Or register individual controllers:

```javascript
import { DropdownController } from "better-page-stimulus"
application.register("dropdown", DropdownController)
```

### Option 2: Rails importmap (via CDN)

Add to your `config/importmap.rb`:

```ruby
pin "better-page-stimulus", to: "https://unpkg.com/better-page-stimulus/src/index.js"
```

Then in your `app/javascript/controllers/index.js`:

```javascript
import { registerBetterPageControllers } from "better-page-stimulus"
registerBetterPageControllers(application)
```

### Option 3: Rails generator (copies files)

If you prefer to have the files locally for customization:

```bash
rails g better_page:install
```

This copies the controllers to `app/javascript/controllers/better_page/`.

## Available Controllers

### Dropdown Controller

A dropdown menu controller with click-outside-to-close functionality.

```html
<div data-controller="dropdown">
  <button data-action="click->dropdown#toggle">
    Menu
  </button>
  <div data-dropdown-target="menu" class="hidden">
    <a href="#">Option 1</a>
    <a href="#">Option 2</a>
  </div>
</div>
```

**Targets:**
- `menu` - The dropdown menu element (toggles `hidden` class)

**Actions:**
- `toggle` - Toggles the menu visibility
- Auto-hides when clicking outside

## Requirements

- `@hotwired/stimulus` ^3.0.0

## License

MIT
