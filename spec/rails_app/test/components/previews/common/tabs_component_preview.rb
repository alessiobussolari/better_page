# frozen_string_literal: true

module Common
  class TabsComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Tabs Component
    # --------------
    # A tabbed interface component for organizing content into panels.
    #
    # **Tab Options:**
    # - `id` - Unique identifier for the tab
    # - `label` - Display text for the tab button
    # - `icon` - Optional icon (SVG or icon class)
    # - `href` - Optional link URL instead of tab panel
    # - `selected` - Set as default selected tab
    #
    # @label Playground
    # @param tab_count [Integer] select { choices: [2, 3, 4, 5] } "Number of tabs"
    # @param show_icons toggle "Show icons on tabs"
    # @param use_links toggle "Use links instead of panels"
    # @param default_selected [Integer] select { choices: [1, 2, 3] } "Default selected tab"
    def playground(tab_count: 3, show_icons: false, use_links: false, default_selected: 1)
      tab_data = [
        { id: "account", label: "Account", icon: account_icon },
        { id: "notifications", label: "Notifications", icon: bell_icon },
        { id: "security", label: "Security", icon: lock_icon },
        { id: "billing", label: "Billing", icon: card_icon },
        { id: "integrations", label: "Integrations", icon: puzzle_icon }
      ].first(tab_count.to_i)

      render BetterPage::Common::TabsComponent.new(id: "tabs-playground") do |tabs|
        tab_data.each_with_index do |tab, index|
          options = {
            id: tab[:id],
            label: tab[:label],
            icon: show_icons ? tab[:icon] : nil,
            active: (index + 1) == default_selected.to_i
          }

          if use_links
            options[:href] = "##{tab[:id]}"
            tabs.with_tab(**options)
          else
            tabs.with_tab(**options) do
              tab_content(tab[:label])
            end
          end
        end
      end
    end

    private

    def tab_content(label)
      <<~HTML.html_safe
        <div class="p-4 bg-gray-50 rounded-lg">
          <h3 class="text-lg font-medium text-gray-900">#{label} Settings</h3>
          <p class="mt-2 text-gray-600">Manage your #{label.downcase} settings and preferences here.</p>
        </div>
      HTML
    end

    def account_icon
      '<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" /></svg>'.html_safe
    end

    def bell_icon
      '<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" /></svg>'.html_safe
    end

    def lock_icon
      '<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" /></svg>'.html_safe
    end

    def card_icon
      '<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5z" /></svg>'.html_safe
    end

    def puzzle_icon
      '<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M14.25 6.087c0-.355.186-.676.401-.959.221-.29.349-.634.349-1.003 0-1.036-1.007-1.875-2.25-1.875s-2.25.84-2.25 1.875c0 .369.128.713.349 1.003.215.283.401.604.401.959v0a.64.64 0 01-.657.643 48.39 48.39 0 01-4.163-.3c.186 1.613.293 3.25.315 4.907a.656.656 0 01-.658.663v0c-.355 0-.676-.186-.959-.401a1.647 1.647 0 00-1.003-.349c-1.036 0-1.875 1.007-1.875 2.25s.84 2.25 1.875 2.25c.369 0 .713-.128 1.003-.349.283-.215.604-.401.959-.401v0c.31 0 .555.26.532.57a48.039 48.039 0 01-.642 5.056c1.518.19 3.058.309 4.616.354a.64.64 0 00.657-.643v0c0-.355-.186-.676-.401-.959a1.647 1.647 0 01-.349-1.003c0-1.035 1.008-1.875 2.25-1.875 1.243 0 2.25.84 2.25 1.875 0 .369-.128.713-.349 1.003-.215.283-.4.604-.4.959v0c0 .333.277.599.61.58a48.1 48.1 0 005.427-.63 48.05 48.05 0 00.582-4.717.532.532 0 00-.533-.57v0c-.355 0-.676.186-.959.401-.29.221-.634.349-1.003.349-1.035 0-1.875-1.007-1.875-2.25s.84-2.25 1.875-2.25c.37 0 .713.128 1.003.349.283.215.604.401.96.401v0a.656.656 0 00.658-.663 48.422 48.422 0 00-.37-5.36c-1.886.342-3.81.574-5.766.689a.578.578 0 01-.61-.58v0z" /></svg>'.html_safe
    end
  end
end
