/* A single native dialog displays the selected faculty dossier; the browser handles focus containment and Escape. */
(() => {
  'use strict';
  const page = document.querySelector('#faculty-page');
  if (!page) return;
  const dialog = page.querySelector('#faculty-profile-dialog');
  const content = dialog.querySelector('[data-faculty-content]');
  let opener = null;

  page.addEventListener('click', (event) => {
    const button = event.target.closest('[data-faculty-open]');
    if (!button) return;
    const template = page.querySelector(`#${button.dataset.facultyOpen}`);
    if (!template) return;
    opener = button;
    content.replaceChildren(template.content.cloneNode(true));
    dialog.showModal();
    document.documentElement.classList.add('mft-profile-open');
    content.scrollTop = 0;
  });
  dialog.querySelector('[data-faculty-close]').addEventListener('click', () => dialog.close());
  let startedOnBackdrop = false;
  dialog.addEventListener('pointerdown', (event) => { startedOnBackdrop = event.target === dialog; });
  dialog.addEventListener('click', (event) => {
    if (startedOnBackdrop && event.target === dialog) {
      const rect = dialog.getBoundingClientRect();
      if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
    }
    startedOnBackdrop = false;
  });
  dialog.addEventListener('close', () => {
    document.documentElement.classList.remove('mft-profile-open');
    content.replaceChildren();
    if (opener?.isConnected) opener.focus({ preventScroll: true });
  });
})();
