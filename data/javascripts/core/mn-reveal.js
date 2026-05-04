// Scroll reveal: fade-in sections as they enter viewport
(function() {
  var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReducedMotion || !('IntersectionObserver' in window)) return;

  document.documentElement.classList.add('scroll-reveal-ready');

  var targets = document.querySelectorAll(
    '.doc-content > div[id], ' +
    '.doc-content > div.section-sub, ' +
    '.doc-content > div[id] > div[id], ' +
    '.doc-content > .main-section > div[id], ' +
    '.doc-content > p.doc-title'
  );

  function checkInitial() {
    targets.forEach(function(el) {
      var rect = el.getBoundingClientRect();
      if (rect.top < window.innerHeight && rect.bottom > 0) {
        el.classList.add('revealed');
      }
    });
  }

  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        observer.unobserve(entry.target);
      }
    });
  }, { rootMargin: '0px 0px -40px 0px', threshold: 0.05 });

  targets.forEach(function(el) { observer.observe(el); });
  checkInitial();
})();
