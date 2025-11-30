import { Controller } from "@hotwired/stimulus"

/**
 * Table Controller
 *
 * A Stimulus controller for table row selection.
 * Connects to data-controller="table"
 *
 * Usage:
 *   <div data-controller="table">
 *     <table>
 *       <thead>
 *         <tr>
 *           <th>
 *             <input type="checkbox"
 *                    data-table-target="selectAll"
 *                    data-action="change->table#selectAll">
 *           </th>
 *         </tr>
 *       </thead>
 *       <tbody>
 *         <tr>
 *           <td>
 *             <input type="checkbox"
 *                    data-table-target="row"
 *                    data-action="change->table#rowChanged">
 *           </td>
 *         </tr>
 *       </tbody>
 *     </table>
 *   </div>
 */
export default class extends Controller {
  static targets = ["selectAll", "row"]

  /**
   * Select or deselect all row checkboxes
   * @param {Event} event - The change event from the select all checkbox
   */
  selectAll(event) {
    const checked = event.target.checked
    this.rowTargets.forEach(checkbox => {
      checkbox.checked = checked
    })
  }

  /**
   * Update the select all checkbox state based on individual row selections
   * Sets indeterminate state when some (but not all) rows are selected
   */
  rowChanged() {
    const total = this.rowTargets.length
    const checked = this.rowTargets.filter(cb => cb.checked).length

    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = checked === total
      this.selectAllTarget.indeterminate = checked > 0 && checked < total
    }
  }
}
