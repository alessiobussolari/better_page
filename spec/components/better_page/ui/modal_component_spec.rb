# frozen_string_literal: true

require "rails_helper"

RSpec.describe BetterPage::Ui::ModalComponent, type: :component do
  describe "rendering" do
    it "renders with title" do
      render_inline(described_class.new(id: "modal-test", title: "Test Modal"))

      expect(page).to have_css("h3", text: "Test Modal")
    end

    it "renders without title" do
      render_inline(described_class.new(id: "modal-test"))

      expect(page).not_to have_css("h3")
    end

    it "renders the modal container" do
      render_inline(described_class.new(id: "modal-test", title: "Test"))

      expect(page).to have_css("div#modal-test")
      expect(page).to have_css("[data-controller='modal']")
    end

    it "renders backdrop with click action" do
      render_inline(described_class.new(id: "modal-test", title: "Test"))

      expect(page).to have_css("[data-modal-target='backdrop']")
      expect(page).to have_css("[data-action='click->modal#backdropClick']")
    end

    it "renders close button when closable" do
      render_inline(described_class.new(id: "modal-test", title: "Test", closable: true))

      expect(page).to have_css("button[data-action='click->modal#requestClose']")
    end

    it "does not render close button when not closable" do
      render_inline(described_class.new(id: "modal-test", title: "Test", closable: false))

      expect(page).not_to have_css("button[data-action='click->modal#requestClose']")
    end

    it "renders with trigger slot" do
      render_inline(described_class.new(id: "modal-test", title: "Test")) do |modal|
        modal.with_trigger { "<button>Open</button>".html_safe }
      end

      expect(page).to have_css("button", text: "Open")
    end

    it "renders with actions slot in footer" do
      render_inline(described_class.new(id: "modal-test", title: "Test", actions_position: :footer)) do |modal|
        modal.with_actions { "<button>Save</button>".html_safe }
      end

      expect(page).to have_css(".bg-gray-50 button", text: "Save")
    end

    it "renders with actions slot in header" do
      render_inline(described_class.new(id: "modal-test", title: "Test", actions_position: :header)) do |modal|
        modal.with_actions { "<button>Edit</button>".html_safe }
      end

      expect(page).to have_css("button", text: "Edit")
    end

    it "renders content" do
      render_inline(described_class.new(id: "modal-test", title: "Test")) do
        "Modal content here"
      end

      expect(page).to have_text("Modal content here")
    end
  end

  describe "size parameter" do
    it "applies normal size by default" do
      render_inline(described_class.new(id: "modal-test"))

      expect(page).to have_css("[data-modal-target='panel'].max-w-md")
    end

    it "applies large size" do
      render_inline(described_class.new(id: "modal-test", size: :large))

      expect(page).to have_css("[data-modal-target='panel'].max-w-2xl")
    end
  end

  describe "confirm_close parameter" do
    it "sets confirm-close value to false by default" do
      render_inline(described_class.new(id: "modal-test"))

      expect(page).to have_css("[data-modal-confirm-close-value='false']")
    end

    it "sets confirm-close value to true when enabled" do
      render_inline(described_class.new(id: "modal-test", confirm_close: true))

      expect(page).to have_css("[data-modal-confirm-close-value='true']")
    end
  end

  describe "predicate methods" do
    it "returns true for closable? when closable" do
      component = described_class.new(id: "modal-test", closable: true)
      expect(component.closable?).to be true
    end

    it "returns false for closable? when not closable" do
      component = described_class.new(id: "modal-test", closable: false)
      expect(component.closable?).to be false
    end

    it "returns true for title? when title present" do
      component = described_class.new(id: "modal-test", title: "Test")
      expect(component.title?).to be true
    end

    it "returns false for title? when title is nil" do
      component = described_class.new(id: "modal-test", title: nil)
      expect(component.title?).to be false
    end

    it "returns true for show_header? when title present" do
      component = described_class.new(id: "modal-test", title: "Test")
      expect(component.show_header?).to be true
    end

    it "returns true for show_header? when closable" do
      component = described_class.new(id: "modal-test", closable: true)
      expect(component.show_header?).to be true
    end

    it "returns false for show_header? when no title and not closable" do
      component = described_class.new(id: "modal-test", title: nil, closable: false)
      expect(component.show_header?).to be false
    end
  end

  describe "#size_class" do
    it "returns normal size class by default" do
      component = described_class.new(id: "modal-test", size: :normal)
      expect(component.size_class).to eq("max-w-md")
    end

    it "returns large size class" do
      component = described_class.new(id: "modal-test", size: :large)
      expect(component.size_class).to eq("max-w-2xl")
    end

    it "falls back to normal for unknown size" do
      component = described_class.new(id: "modal-test", size: :unknown)
      expect(component.size_class).to eq("max-w-md")
    end
  end

  describe "#panel_classes" do
    it "includes common panel classes" do
      component = described_class.new(id: "modal-test")
      classes = component.panel_classes

      expect(classes).to include("bg-white")
      expect(classes).to include("shadow-xl")
      expect(classes).to include("rounded-lg")
    end

    it "includes size class" do
      component = described_class.new(id: "modal-test", size: :large)
      expect(component.panel_classes).to include("max-w-2xl")
    end
  end

  describe "actions_position" do
    it "sets header_actions? correctly" do
      render_inline(described_class.new(id: "modal-test", title: "Test", actions_position: :header)) do |modal|
        modal.with_actions { "<button>Save</button>".html_safe }
        "Content"
      end

      expect(page).to have_css(".border-b button", text: "Save")
    end

    it "sets footer_actions? correctly" do
      render_inline(described_class.new(id: "modal-test", title: "Test", actions_position: :footer)) do |modal|
        modal.with_actions { "<button>Save</button>".html_safe }
        "Content"
      end

      expect(page).to have_css(".border-t.bg-gray-50 button", text: "Save")
    end
  end
end
