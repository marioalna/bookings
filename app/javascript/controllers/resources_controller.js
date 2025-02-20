import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="resources"
export default class extends Controller {
  static targets = ["resourceId", "bookingImage"];
  static values = { rid: Number };

  connect() {
    this.resourceId = 0;
    if (this.resourceIdTarget.value) {
      this.resourceId = parseInt(this.resourceIdTarget.value);
    }
    if (this.resourceId == this.ridValue) {
      this.bookingImageTarget.classList.add("border-4", "border-blue-500");
    }
  }

  toggle(_event) {
    if (this.resourceId == this.ridValue) {
      this.resourceIdTarget.value = "";
      this.bookingImageTarget.classList.remove("border-4", "border-blue-500");
    } else {
      this.resourceIdTarget.value = this.ridValue;
      this.bookingImageTarget.classList.add("border-4", "border-blue-500");
    }
  }
}
