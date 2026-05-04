// Index panel: quick-nav letter bar and active letter highlighting
(function() {
  var indexSection = document.querySelector('[data-component="index"]');
  if (!indexSection) return;

  var letters = indexSection.querySelectorAll('.index-letter');
  if (letters.length === 0) return;

  // Build quick-nav map from existing nav links
  var letterAnchors = {};
  indexSection.querySelectorAll('.index-quicknav a').forEach(function(anchor) {
    var letter = anchor.textContent.trim();
    letterAnchors[letter] = anchor;
  });

  // Highlight active letter on scroll
  if ('IntersectionObserver' in window) {
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        var letter = entry.target.textContent.trim();
        var anchor = letterAnchors[letter];
        if (!anchor) return;
        if (entry.isIntersecting) {
          anchor.classList.add('active');
        } else {
          anchor.classList.remove('active');
        }
      });
    }, { rootMargin: '-80px 0px -80% 0px' });

    letters.forEach(function(h3) { observer.observe(h3); });
  }
})();
