import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    event.preventDefault();
    const frameId = event.currentTarget.closest("[data-attachment-id]")?.getAttribute("data-attachment-id") || event.currentTarget.closest("span")?.nextElementSibling?.id;
    if (!frameId) return;
    // Replace with your actual Rails path for the copyright edit form
    const url = `/admin/attachments/${frameId}/edit_metadata`;
    const frame = document.getElementById(`copyright_modal_${frameId}`);
    if (frame) {
      frame.src = url;
      frame.style.display = "block";
    }
  }

  close(event) {
    event.preventDefault();
    // Find the closest turbo-frame ancestor and clear its content
    const frame = event.target.closest('turbo-frame');
    if (frame) {
      frame.innerHTML = '';
    }
    // trigger turbo refresh to reload the page content behind the modal
    Turbo.visit(window.location.href, { action: 'replace' });
  }

  stopPropagation(event) {
    event.stopPropagation();
  }
}
