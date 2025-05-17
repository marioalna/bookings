import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modalDialog"];
  static values = { background: Boolean };

  connect() {
    this.show();
  }

  show() {
    this.modalDialogTarget.showModal();
  }

  close() {
    this.element.parentElement.removeAttribute("src");
    this.element.parentElement.innerHTML = "";
    this.modalDialogTarget.close();
  }

  submitEnd(event) {
    if (
      event.detail.success &&
      event.detail.fetchResponse.response.redirected === true
    ) {
      this.close();
    }
  }

  closeWithEsc(event) {
    if (event.code == "Escape") {
      this.close();
    }
  }
}
