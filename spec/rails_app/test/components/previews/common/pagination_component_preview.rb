# frozen_string_literal: true

module Common
  class PaginationComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # Pagination Component
    # --------------------
    # Displays page navigation with record information.
    #
    # **Position States:**
    # - First page - Previous button disabled
    # - Middle page - Both buttons enabled
    # - Last page - Next button disabled
    #
    # @label Playground
    # @param position [Symbol] select { choices: [first, middle, last] } "Page position"
    # @param total_pages [Integer] select { choices: [5, 10, 50] } "Total pages"
    def playground(position: :middle, total_pages: 10)
      pages = total_pages.to_i
      per_page = 25

      current = case position.to_sym
      when :first then 1
      when :last then pages
      else (pages / 2.0).ceil
      end

      total_records = pages * per_page - rand(0..per_page)
      start_record = (current - 1) * per_page + 1
      end_record = [ current * per_page, total_records ].min

      render BetterPage::Common::PaginationComponent.new(
        current_page: current,
        total_pages: pages,
        start_record: start_record,
        end_record: end_record,
        total_records: total_records,
        base_path: "/products"
      )
    end
  end
end
