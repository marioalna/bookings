import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

// Connects to data-controller="booking"
export default class extends Controller {
  static targets = ["startOn", "participants", "scheduleCategoryId", "message"];
  static values = { resources: Object, capacity: Number, translations: Object };

  connect() {
    this.resourcesAssigned = [];
    this.element.querySelectorAll('[data-resource-target="resource"]').forEach((input) => {
      if (input.value) {
        this.resourcesAssigned.push(parseInt(input.value));
      }
    });
  }

  toggle(event) {
    const id = event.params.id;
    const resource = this.resourcesValue[id];
    const index = this.resourcesAssigned.indexOf(id);

    if (index !== -1) {
      this.resourcesAssigned.splice(index, 1);
    } else {
      this.resourcesAssigned.push(id);
    }

    this.assignedDifference();
  }

  assignedDifference() {
    if (this.participantsTarget.value > this.capacityValue) {
      this.removeClassList();
      this.messageTarget.innerHTML =
        this.translationsValue["exceeded"].translation;
      this.messageTarget.classList.remove();
      this.messageTarget.classList.add("text-red-600");
      this.messageTarget.innerHTML = this.messageTarget.innerHTML.replace(
        "XX",
        `${this.capacityValue}`
      );
      this.messageTarget.innerHTML = this.messageTarget.innerHTML.replace(
        "YY",
        `${Math.abs(this.capacityValue - this.participantsTarget.value)}`
      );
    } else {
      this.calculatePending();
    }
  }

  calculatePending() {
    const pending = this.participantsTarget.value - this.totalAssigned();
    if (pending > 0) {
      this.removeClassList();
      this.messageTarget.classList.add("text-yellow-600");
      this.messageTarget.innerHTML =
        this.translationsValue["notEnough"].translation;
      this.messageTarget.innerHTML = this.messageTarget.innerHTML.replace(
        "X",
        `${pending}`
      );
    } else {
      this.removeClassList();
      this.messageTarget.innerHTML =
        this.translationsValue["enough"].translation;
      this.messageTarget.classList.add("text-green-600");
    }
  }

  totalAssigned() {
    let assigned = 0;
    this.resourcesAssigned.forEach((id) => {
      assigned += this.resourcesValue[id].max_capacity;
    });

    return assigned;
  }

  removeClassList() {
    while (this.messageTarget.classList.length > 0) {
      this.messageTarget.classList.remove(this.messageTarget.classList.item(0));
    }
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
