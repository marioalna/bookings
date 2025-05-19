import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["show", "hide"];

  connect() {
    this.element.classList.add(this.showClass);
    this.showTimer = setTimeout(() => {
      this.hide();
    }, 3000);
  }

  disconnect() {
    this.stopTimer();
  }

  hide() {
    this.element.classList.remove(this.showClass);
    this.element.classList.add(this.hideClass);
  }

  stopTimer() {
    if (this.showTimer) {
      clearInterval(this.showTimer)
    }
  }
}
