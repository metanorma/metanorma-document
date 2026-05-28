// Lightbox: click images to view full-size overlay with caption
(function() {
  document.addEventListener('click', function(e) {
    var img = e.target.closest('figure img, .doc-content img:not(.brand-logo img):not(.footer-mn-logo img)');
    if (!img || img.naturalWidth < 100 || img.naturalHeight < 100) return;

    var overlay = document.createElement('div');
    overlay.className = 'lightbox-overlay';

    var inner = document.createElement('div');
    inner.className = 'lightbox-inner';

    var clone = document.createElement('img');
    clone.src = img.src;
    clone.alt = img.alt || '';

    inner.appendChild(clone);

    var figure = img.closest('figure');
    if (figure) {
      var caption = figure.querySelector('figcaption');
      if (caption) {
        var captionClone = document.createElement('div');
        captionClone.className = 'lightbox-caption';
        captionClone.innerHTML = caption.innerHTML;
        inner.appendChild(captionClone);
      }
    }

    overlay.appendChild(inner);
    document.body.appendChild(overlay);
    overlay.addEventListener('click', function() { overlay.remove(); });
  });
})();
