# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Ui::TabsComponent, type: :component do
  describe "rendering" do
    it "renders tabs with content" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      expect(page).to have_css("div#test-tabs")
      expect(page).to have_css("[data-controller='tabs']")
      expect(page).to have_css("button", text: "Tab 1")
      expect(page).to have_css("button", text: "Tab 2")
      expect(page).to have_text("Content 1")
      expect(page).to have_text("Content 2")
    end

    it "renders navigation with tablist role" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
      end

      expect(page).to have_css("nav[role='tablist']")
    end

    it "renders tab buttons with correct attributes" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
      end

      expect(page).to have_css("button[role='tab']")
      expect(page).to have_css("button[data-tabs-target='tab']")
      expect(page).to have_css("button[data-action='click->tabs#select keydown->tabs#keydown']")
    end

    it "renders panels with correct attributes" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
      end

      expect(page).to have_css("div[role='tabpanel']")
      expect(page).to have_css("div[data-tabs-target='panel']")
    end

    it "sets aria-controls and aria-labelledby correctly" do
      render_inline(described_class.new(id: "my-tabs")) do |tabs|
        tabs.with_tab(id: "account", label: "Account") { "Account content" }
      end

      expect(page).to have_css("button#my-tabs-tab-account[aria-controls='my-tabs-panel-account']")
      expect(page).to have_css("div#my-tabs-panel-account[aria-labelledby='my-tabs-tab-account']")
    end

    it "applies underline style classes" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
      end

      expect(page).to have_css("nav.border-b.border-gray-200")
      expect(page).to have_css("button.border-b-2")
    end
  end

  describe "default tab selection" do
    it "selects first tab by default" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      expect(page).to have_css("button[data-tab-id='tab1'][aria-selected='true']")
      expect(page).to have_css("button[data-tab-id='tab2'][aria-selected='false']")
      expect(page).to have_css("div[data-tab-id='tab2'].hidden")
    end

    it "selects specified default tab" do
      render_inline(described_class.new(id: "test-tabs", default_tab: "tab2")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "tab2", label: "Tab 2") { "Content 2" }
      end

      expect(page).to have_css("button[data-tab-id='tab1'][aria-selected='false']")
      expect(page).to have_css("button[data-tab-id='tab2'][aria-selected='true']")
      expect(page).to have_css("div[data-tab-id='tab1'].hidden")
    end
  end

  describe "link tabs" do
    it "renders link tabs as anchors" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
        tabs.with_tab(id: "link-tab", label: "External", href: "/other-page")
      end

      expect(page).to have_css("a[href='/other-page']", text: "External")
      expect(page).to have_css("button", text: "Tab 1")
    end

    it "does not render panels for link tabs" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "link-tab", label: "External", href: "/other-page")
      end

      expect(page).not_to have_css("div[role='tabpanel']")
    end

    it "applies active class to active link tab" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "link-tab", label: "Active Link", href: "/page", active: true)
      end

      expect(page).to have_css("a.border-blue-600", text: "Active Link")
    end

    it "mixes link and content tabs" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "content1", label: "Content Tab") { "Content here" }
        tabs.with_tab(id: "link1", label: "Link Tab", href: "/page")
        tabs.with_tab(id: "content2", label: "Another Tab") { "More content" }
      end

      expect(page).to have_css("button", count: 2)
      expect(page).to have_css("a", count: 1)
      expect(page).to have_css("div[role='tabpanel']", count: 2)
    end
  end

  describe "stimulus data attributes" do
    it "sets default value" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
      end

      expect(page).to have_css("[data-tabs-default-value='tab1']")
    end

    it "sets active and inactive class values" do
      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1") { "Content 1" }
      end

      expect(page).to have_css("[data-tabs-active-class]")
      expect(page).to have_css("[data-tabs-inactive-class]")
    end
  end

  describe "tab with icon" do
    it "renders icon when provided" do
      icon = "<svg class='h-5 w-5'></svg>".html_safe

      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "tab1", label: "Tab 1", icon: icon) { "Content 1" }
      end

      expect(page).to have_css("button svg.h-5.w-5")
    end

    it "renders icon in link tabs" do
      icon = "<svg class='icon'></svg>".html_safe

      render_inline(described_class.new(id: "test-tabs")) do |tabs|
        tabs.with_tab(id: "link1", label: "Link", href: "/page", icon: icon)
      end

      expect(page).to have_css("a svg.icon")
    end
  end

  describe "#default_tab_id" do
    it "returns default_tab when specified" do
      component = described_class.new(id: "test-tabs", default_tab: "settings")
      expect(component.default_tab_id).to eq("settings")
    end
  end

  describe "#default_index" do
    it "returns 0 when no default_tab specified" do
      component = described_class.new(id: "test-tabs")
      expect(component.default_index).to eq(0)
    end
  end

  describe "#nav_classes" do
    it "includes flex and style nav classes" do
      component = described_class.new(id: "test-tabs")
      expect(component.nav_classes).to include("flex")
      expect(component.nav_classes).to include("border-b")
    end
  end

  describe "TabItem" do
    describe "#icon?" do
      it "returns true when icon is present" do
        tab = described_class::TabItem.new(id: "tab1", label: "Tab", icon: "<svg></svg>".html_safe)
        expect(tab.icon?).to be true
      end

      it "returns false when icon is nil" do
        tab = described_class::TabItem.new(id: "tab1", label: "Tab", icon: nil)
        expect(tab.icon?).to be false
      end
    end

    describe "#link?" do
      it "returns true when href is present" do
        tab = described_class::TabItem.new(id: "tab1", label: "Tab", href: "/page")
        expect(tab.link?).to be true
      end

      it "returns false when href is nil" do
        tab = described_class::TabItem.new(id: "tab1", label: "Tab")
        expect(tab.link?).to be false
      end
    end

    describe "#active?" do
      it "returns true when active is true" do
        tab = described_class::TabItem.new(id: "tab1", label: "Tab", href: "/page", active: true)
        expect(tab.active?).to be true
      end

      it "returns false by default" do
        tab = described_class::TabItem.new(id: "tab1", label: "Tab", href: "/page")
        expect(tab.active?).to be false
      end
    end
  end
end
