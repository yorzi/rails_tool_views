// Host imports and registers this factory with its own Stimulus application.
// No provider, generated code, or browser-owned policy participates in actions.
export default function railsToolViewsController(Controller) {
  return class extends Controller {
    static targets = ["status", "error"];
    // The server-rendered Surface supplies translated copy; these are fallbacks.
    static values = {
      revision: Number,
      saving: { type: String, default: "Saving changes…" },
      failed: { type: String, default: "Changes could not be saved. Review the message and try again." }
    };
    connect() {
      this.start = () => {
        this.element.setAttribute("aria-busy", "true");
        if (this.hasStatusTarget) this.statusTarget.textContent = this.savingValue;
      };
      this.end = (event) => {
        this.element.removeAttribute("aria-busy");
        if (!event.detail.success && this.hasStatusTarget) this.statusTarget.textContent = this.failedValue;
      };
      this.beforeStream = (event) => {
        const stream = event.target;
        if (stream.getAttribute("target") !== this.element.id) return;
        const incoming = stream.querySelector("template")?.content.firstElementChild;
        const revision = Number(incoming?.getAttribute("data-rails-tool-views-revision-value"));
        if (revision && revision < this.revisionValue) event.preventDefault();
      };
      this.element.ownerDocument.addEventListener("turbo:before-stream-render", this.beforeStream);
      this.element.addEventListener("turbo:submit-start", this.start);
      this.element.addEventListener("turbo:submit-end", this.end);
      // Replacement happens after a committed result; move focus to its announcement.
      if (this.hasErrorTarget) this.errorTarget.focus({ preventScroll: true });
      else if (this.revisionValue > 1 && this.hasStatusTarget) this.statusTarget.focus({ preventScroll: true });
    }
    disconnect() {
      this.element.ownerDocument.removeEventListener("turbo:before-stream-render", this.beforeStream);
      this.element.removeEventListener("turbo:submit-start", this.start);
      this.element.removeEventListener("turbo:submit-end", this.end);
    }
  };
}
