import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

// Connects to data-controller="booking"
export default class extends Controller {
  static targets = [
    "startOn",
    "participants",
    "scheduleCategoryId",
    "bookingImage",
  ];
  static values = { resources: Object };

  connect() {
    this.resourcesAssigned = [];
  }

  toggle(event) {
    const id = event.params.id;
    const resource = this.resourcesValue[id];
    const index = this.resourcesAssigned.indexOf(id);

    if (index !== -1) {
      this.bookingImageTarget.classList.remove("border-4", "border-blue-500");
      this.resourcesAssigned.splice(index, 1);
    } else {
      this.bookingImageTarget.classList.add("border-4", "border-blue-500");
      this.resourcesAssigned.push(id);
    }

    this.assignedDifference();
  }

  assignedDifference() {
    const pending = this.participantsTarget.value - this.totalAssigned();
    if (pending <= 0) {
      console.log("Ya tienes suficientes recursos asignados");
      console.log(this.bookingImageTarget);
    } else {
      console.log(
        `Tienes pendiente asignar espacio para ${pending} comensales`
      );
    }
  }

  removeViewValues() {}

  totalAssigned() {
    let assigned = 0;
    this.resourcesAssigned.forEach((id) => {
      assigned += this.resourcesValue[id].max_capacity;
    });

    return assigned;
  }

  //async update() {
  //  const data = {
  //    start_on: this.startOnTarget.value,
  //    schedule_category_id: this.scheduleCategoryIdTarget.value,
  //  };
  //
  //  const resp = await post("/bookings/check", {
  //    headers: { Accept: "text/vnd.turbo-stream.html" },
  //    responseKind: "turbo-stream",
  //    body: JSON.stringify(data),
  //  });
  //
  //  if (resp.ok) {
  //    const text = await resp.text;
  //    Turbo.renderStreamMessage(text);
  //  }
  //}
}
