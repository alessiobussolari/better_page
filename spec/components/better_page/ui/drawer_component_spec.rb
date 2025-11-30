# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Ui::DrawerComponent, type: :component do
  describe "rendering" do
    it "renders with title" do
      render_inline(described_class.new(id: "drawer-test", title: "Test Drawer"))

      expect(page).to have_css("h2", text: "Test Drawer")
    end

    it "renders without title" do
      render_inline(described_class.new(id: "drawer-test"))

      expect(page).not_to have_css("h2")
    end

    it "renders the drawer container" do
      render_inline(described_class.new(id: "drawer-test", title: "Test"))

      expect(page).to have_css("div#drawer-test")
      expect(page).to have_css("[data-controller='drawer']")
    end

    it "renders backdrop with click action" do
      render_inline(described_class.new(id: "drawer-test", title: "Test"))

      expect(page).to have_css("[data-drawer-target='backdrop']")
      expect(page).to have_css("[data-action='click->drawer#backdropClick']")
    end

    it "renders close button when closable" do
      render_inline(described_class.new(id: "drawer-test", title: "Test", closable: true))

      expect(page).to have_css("button[data-action='click->drawer#requestClose']")
    end

    it "does not render close button when not closable" do
      render_inline(described_class.new(id: "drawer-test", title: "Test", closable: false))

      expect(page).not_to have_css("button[data-action='click->drawer#requestClose']")
    end

    it "renders with trigger slot" do
      render_inline(described_class.new(id: "drawer-test", title: "Test")) do |drawer|
        drawer.with_trigger { "<button>Open</button>".html_safe }
      end

      expect(page).to have_css("button", text: "Open")
    end

    it "renders with actions slot in header" do
      render_inline(described_class.new(id: "drawer-test", title: "Test", actions_position: :header)) do |drawer|
        drawer.with_actions { "<button>Save</button>".html_safe }
      end

      expect(page).to have_css("button", text: "Save")
    end

    it "renders with actions slot in footer" do
      render_inline(described_class.new(id: "drawer-test", title: "Test", actions_position: :footer)) do |drawer|
        drawer.with_actions { "<button>Save</button>".html_safe }
      end

      expect(page).to have_css(".bg-gray-50 button", text: "Save")
    end

    it "renders content" do
      render_inline(described_class.new(id: "drawer-test", title: "Test")) do
        "Drawer content here"
      end

      expect(page).to have_text("Drawer content here")
    end
  end

  describe "direction parameter" do
    it "sets direction value for right" do
      render_inline(described_class.new(id: "drawer-test", direction: :right))

      expect(page).to have_css("[data-drawer-direction-value='right']")
    end

    it "sets direction value for left" do
      render_inline(described_class.new(id: "drawer-test", direction: :left))

      expect(page).to have_css("[data-drawer-direction-value='left']")
    end

    it "sets direction value for top" do
      render_inline(described_class.new(id: "drawer-test", direction: :top))

      expect(page).to have_css("[data-drawer-direction-value='top']")
    end

    it "sets direction value for bottom" do
      render_inline(described_class.new(id: "drawer-test", direction: :bottom))

      expect(page).to have_css("[data-drawer-direction-value='bottom']")
    end
  end

  describe "confirm_close parameter" do
    it "sets confirm-close value to false by default" do
      render_inline(described_class.new(id: "drawer-test"))

      expect(page).to have_css("[data-drawer-confirm-close-value='false']")
    end

    it "sets confirm-close value to true when enabled" do
      render_inline(described_class.new(id: "drawer-test", confirm_close: true))

      expect(page).to have_css("[data-drawer-confirm-close-value='true']")
    end
  end

  describe "predicate methods" do
    it "returns true for closable? when closable" do
      component = described_class.new(id: "drawer-test", closable: true)
      expect(component.closable?).to be true
    end

    it "returns false for closable? when not closable" do
      component = described_class.new(id: "drawer-test", closable: false)
      expect(component.closable?).to be false
    end

    it "returns true for title? when title present" do
      component = described_class.new(id: "drawer-test", title: "Test")
      expect(component.title?).to be true
    end

    it "returns false for title? when title is nil" do
      component = described_class.new(id: "drawer-test", title: nil)
      expect(component.title?).to be false
    end

    it "returns true for show_header? when title present" do
      component = described_class.new(id: "drawer-test", title: "Test")
      expect(component.show_header?).to be true
    end

    it "returns true for show_header? when closable" do
      component = described_class.new(id: "drawer-test", closable: true)
      expect(component.show_header?).to be true
    end

    it "returns false for show_header? when no title and not closable" do
      component = described_class.new(id: "drawer-test", title: nil, closable: false)
      expect(component.show_header?).to be false
    end
  end

  describe "#panel_position_class" do
    let(:component) { described_class.new(id: "drawer-test") }

    it "returns right position classes" do
      component = described_class.new(id: "drawer-test", direction: :right)
      expect(component.panel_position_class).to include("right-0")
      expect(component.panel_position_class).to include("inset-y-0")
    end

    it "returns left position classes" do
      component = described_class.new(id: "drawer-test", direction: :left)
      expect(component.panel_position_class).to include("left-0")
      expect(component.panel_position_class).to include("inset-y-0")
    end

    it "returns top position classes" do
      component = described_class.new(id: "drawer-test", direction: :top)
      expect(component.panel_position_class).to include("top-0")
      expect(component.panel_position_class).to include("inset-x-0")
    end

    it "returns bottom position classes" do
      component = described_class.new(id: "drawer-test", direction: :bottom)
      expect(component.panel_position_class).to include("bottom-0")
      expect(component.panel_position_class).to include("inset-x-0")
    end
  end

  describe "#panel_size_class" do
    it "returns normal size for horizontal drawers" do
      component = described_class.new(id: "drawer-test", direction: :right, size: :normal)
      expect(component.panel_size_class).to include("max-w-md")
    end

    it "returns large size for horizontal drawers" do
      component = described_class.new(id: "drawer-test", direction: :right, size: :large)
      expect(component.panel_size_class).to include("max-w-2xl")
    end

    it "returns normal size for vertical drawers" do
      component = described_class.new(id: "drawer-test", direction: :bottom, size: :normal)
      expect(component.panel_size_class).to include("max-h-[50vh]")
    end

    it "returns large size for vertical drawers" do
      component = described_class.new(id: "drawer-test", direction: :bottom, size: :large)
      expect(component.panel_size_class).to include("max-h-[80vh]")
    end
  end

  describe "#panel_classes" do
    it "returns horizontal panel classes" do
      component = described_class.new(id: "drawer-test", direction: :right)
      classes = component.panel_classes

      expect(classes).to include("bg-white")
      expect(classes).to include("shadow-xl")
      expect(classes).to include("h-full")
    end

    it "returns vertical panel classes" do
      component = described_class.new(id: "drawer-test", direction: :bottom)
      classes = component.panel_classes

      expect(classes).to include("bg-white")
      expect(classes).to include("shadow-xl")
      expect(classes).not_to include("h-full")
    end
  end

  describe "#initial_transform_class" do
    it "returns translate-x-full for right" do
      component = described_class.new(id: "drawer-test", direction: :right)
      expect(component.initial_transform_class).to eq("translate-x-full")
    end

    it "returns -translate-x-full for left" do
      component = described_class.new(id: "drawer-test", direction: :left)
      expect(component.initial_transform_class).to eq("-translate-x-full")
    end

    it "returns -translate-y-full for top" do
      component = described_class.new(id: "drawer-test", direction: :top)
      expect(component.initial_transform_class).to eq("-translate-y-full")
    end

    it "returns translate-y-full for bottom" do
      component = described_class.new(id: "drawer-test", direction: :bottom)
      expect(component.initial_transform_class).to eq("translate-y-full")
    end
  end

  describe "actions_position" do
    it "renders actions in header by default" do
      component = described_class.new(id: "drawer-test", title: "Test", actions_position: :header)

      expect(component.header_actions?).to be false # no actions slot yet
      expect(component.footer_actions?).to be false
    end

    it "sets header_actions? correctly" do
      render_inline(described_class.new(id: "drawer-test", title: "Test", actions_position: :header)) do |drawer|
        drawer.with_actions { "<button>Save</button>".html_safe }
        "Content"
      end

      expect(page).to have_css(".border-b button", text: "Save")
    end

    it "sets footer_actions? correctly" do
      render_inline(described_class.new(id: "drawer-test", title: "Test", actions_position: :footer)) do |drawer|
        drawer.with_actions { "<button>Save</button>".html_safe }
        "Content"
      end

      expect(page).to have_css(".border-t.bg-gray-50 button", text: "Save")
    end
  end
end
