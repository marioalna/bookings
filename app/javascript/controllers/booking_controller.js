import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

// Connects to data-controller="booking"
export default class extends Controller {
  static targets = ["startOn", "scheduleCategoryId"];

  connect() {
    this.csrfToken = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");
  }

  async update() {
    const data = {
      start_on: this.startOnTarget.value,
      schedule_category_id: this.scheduleCategoryIdTarget.value,
    };

    const resp = await post("/bookings/check", {
      headers: { Accept: "text/vnd.turbo-stream.html" },
      responseKind: "turbo-stream",
      body: JSON.stringify(data),
    });

    if (resp.ok) {
      const text = await resp.text;
      Turbo.renderStreamMessage(text);
    }
  }
}
