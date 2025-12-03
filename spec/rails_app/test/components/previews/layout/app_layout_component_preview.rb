# frozen_string_literal: true

module Layout
  class AppLayoutComponentPreview < ViewComponent::Preview
    layout false

    # App Layout Component
    # --------------------
    # A complete layout component that manages sidebar, topbar, dock and content area.
    #
    # **Features:**
    # - Fixed sidebar on desktop (hidden on mobile)
    # - Sticky topbar with breadcrumbs and user menu
    # - Mobile dock navigation (hidden on desktop)
    # - Content area with automatic margin adjustment
    #
    # **Responsive behavior:**
    # - Desktop: Sidebar visible, dock hidden
    # - Mobile: Sidebar hidden, dock visible
    #
    # @label Playground
    # @param sidebar_collapsed toggle "Collapse sidebar"
    # @param show_topbar toggle "Show topbar"
    # @param show_dock toggle "Show mobile dock"
    def playground(sidebar_collapsed: false, show_topbar: true, show_dock: true)
      render BetterPage::Layout::AppLayoutComponent.new(
        sidebar_collapsed: sidebar_collapsed
      ) do |layout|
        # Sidebar
        layout.with_sidebar(brand: "BetterPage", collapsible: true, collapsed: sidebar_collapsed) do |sidebar|
          sidebar.with_item(id: "dashboard", label: "Dashboard", icon: "fa-solid fa-home", href: "#", active: true)
          sidebar.with_item(id: "users", label: "Users", icon: "fa-solid fa-users", href: "#")
          sidebar.with_item(id: "products", label: "Products", icon: "fa-solid fa-box", href: "#", badge: "12")
          sidebar.with_item(id: "orders", label: "Orders", icon: "fa-solid fa-shopping-cart", href: "#")
          sidebar.with_item(id: "settings", label: "Settings", icon: "fa-solid fa-cog", href: "#")
        end

        # Topbar
        if show_topbar
          layout.with_topbar do |topbar|
            topbar.with_breadcrumb(label: "Home", href: "#", icon: "fa-solid fa-home")
            topbar.with_breadcrumb(label: "Users", href: "#")
            topbar.with_breadcrumb(label: "John Doe", current: true)

            topbar.with_context_info(label: "Production", variant: :success, dot: true)

            topbar.with_notification(id: "notif", icon: "fa-solid fa-bell", badge: "3", href: "#")

            topbar.with_user_menu(name: "John Doe", email: "john@example.com") do |menu|
              menu.with_menu_item(id: "profile", label: "Profile", icon: "fa-solid fa-user", href: "#")
              menu.with_menu_item(id: "settings", label: "Settings", icon: "fa-solid fa-cog", href: "#")
              menu.with_menu_item(id: "logout", label: "Logout", icon: "fa-solid fa-sign-out-alt", href: "#", destructive: true)
            end
          end
        end

        # Dock (mobile)
        if show_dock
          layout.with_dock do |dock|
            dock.with_tab(id: "home", label: "Home", icon: "fa-solid fa-home", active: true, href: "#")
            dock.with_tab(id: "search", label: "Search", icon: "fa-solid fa-search", href: "#")
            dock.with_tab(id: "cart", label: "Cart", icon: "fa-solid fa-shopping-cart", badge: "3", href: "#")
            dock.with_tab(id: "profile", label: "Profile", icon: "fa-solid fa-user", href: "#")
          end
        end

        # Content
        content_tag(:div, class: "space-y-6") do
          safe_join([
            content_tag(:div, class: "bg-white rounded-xl shadow p-6") do
              content_tag(:h1, "Dashboard", class: "text-2xl font-bold text-gray-900 mb-4") +
              content_tag(:p, "Welcome to your application dashboard. This is the main content area.", class: "text-gray-600")
            end,
            content_tag(:div, class: "grid grid-cols-1 md:grid-cols-3 gap-6") do
              safe_join([
                stat_card("Total Users", "1,234", "+12%"),
                stat_card("Revenue", "$45,678", "+8%"),
                stat_card("Orders", "567", "+23%")
              ])
            end,
            content_tag(:div, class: "bg-white rounded-xl shadow p-6") do
              content_tag(:h2, "Recent Activity", class: "text-lg font-semibold text-gray-900 mb-4") +
              content_tag(:p, "Activity feed would go here...", class: "text-gray-500")
            end
          ])
        end
      end
    end

    private

    def stat_card(title, value, change)
      content_tag(:div, class: "bg-white rounded-xl shadow p-6") do
        content_tag(:p, title, class: "text-sm text-gray-500") +
        content_tag(:p, value, class: "text-2xl font-bold text-gray-900 mt-1") +
        content_tag(:p, change, class: "text-sm text-green-600 mt-1")
      end
    end
  end
end
