import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["field", "checked"];

  connect() {
    this.updateSelectors();
  }

  update({ params }) {
    this.fieldTarget.value = params.colour;
    this.updateSelectors();
  }

  updateSelectors() {
    this.checkedTargets.forEach((check) => {
      if (check.dataset.colour != this.fieldTarget.value) {
        check.classList.remove("border-2", "border-gray-700");
      } else {
        check.classList.add("border-2", "border-gray-700");
      }
    });
  }
}
