import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selected", "resource"];
  static values = { id: Number };

  connect() {
    if (this.resourceTarget.value) {
      this.selectedTarget.classList.add("border-4", "border-blue-500");
    }
  }

  toggle() {
    if (this.resourceTarget.value) {
      this.resourceTarget.value = "";
      this.selectedTarget.classList.remove("border-4", "border-blue-500");
    } else {
      this.resourceTarget.value = this.idValue;
      this.selectedTarget.classList.add("border-4", "border-blue-500");
    }
  }
}
