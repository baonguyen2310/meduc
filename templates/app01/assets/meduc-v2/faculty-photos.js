/* Portrait uploads keep their framing; landscape course posters retain their existing crop. */
(() => {
  'use strict';
  if (window.MeducFacultyPhotos) {
    window.MeducFacultyPhotos.refresh(document);
    return;
  }

  const selector = '.mgv-photo img, .mft-portrait img, .mft-dossier-photo img, .mhw-tile img';
  const framePortrait = (image) => {
    if (!image.matches(selector) || !image.naturalWidth || image.naturalHeight < image.naturalWidth * 1.25) return;
    const card = image.closest('.mgv-card');
    if (card) card.classList.add('mgv-card--portrait');
    const frame = image.closest('.mft-portrait, .mft-dossier-photo, .mhw-tile');
    if (!frame) return;
    if (frame.classList.contains('mft-portrait')) frame.classList.add('mft-portrait--portrait');
    if (frame.classList.contains('mft-dossier-photo')) frame.classList.add('mft-dossier-photo--portrait');
    if (frame.classList.contains('mhw-tile')) frame.classList.add('mhw-tile--portrait');
  };
  const refresh = (root) => {
    root.querySelectorAll(selector).forEach((image) => {
      if (image.complete) framePortrait(image);
    });
  };

  // Capturing handles lazy images and photos inserted when opening a profile dialog.
  document.addEventListener('load', (event) => {
    if (event.target instanceof HTMLImageElement) framePortrait(event.target);
  }, true);
  window.MeducFacultyPhotos = { refresh };
  refresh(document);
})();
