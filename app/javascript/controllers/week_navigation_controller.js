import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["week", "label"]
  static values = { current: Number, total: Number }

  connect() {
    this.showWeek(this.currentValue)
  }

  previous() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.showWeek(this.currentValue)
    }
  }

  next() {
    if (this.currentValue < this.totalValue - 1) {
      this.currentValue++
      this.showWeek(this.currentValue)
    }
  }

  showWeek(index) {
    this.weekTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== index)
    })
    this.labelTarget.textContent = `Semana ${index + 1} de ${this.totalValue}`
  }
}
