// Lightbox: click images to view full-size overlay
(function() {
  document.addEventListener('click', function(e) {
    var img = e.target.closest('figure img, .doc-content img:not(.brand-logo img):not(.footer-mn-logo img)');
    if (!img || img.naturalWidth < 100 || img.naturalHeight < 100) return;

    var overlay = document.createElement('div');
    overlay.className = 'lightbox-overlay';

    var clone = document.createElement('img');
    clone.src = img.src;
    clone.alt = img.alt || '';

    overlay.appendChild(clone);
    document.body.appendChild(overlay);
    overlay.addEventListener('click', function() { overlay.remove(); });
  });
})();
