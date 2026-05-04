// Scroll: progress bar, scroll memory, back-to-top, header auto-hide
(function() {
  var R = window.MetanormaReader;
  var progressBar = document.getElementById('reading-progress');
  var backToTop = document.getElementById('back-to-top');
  var header = document.querySelector('.doc-header');
  var SCROLL_KEY = 'mn-scroll-' + location.pathname;
  var ticking = false;
  var lastScroll = 0;
  var scrollThreshold = 10;
  var FULL_HEIGHT = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--header-height')) || 52;
  var COMPACT_HEIGHT = 40;

  function setHeaderHeight(h) {
    document.documentElement.style.setProperty('--header-height', h + 'px');
  }

  function updateProgress() {
    if (!progressBar) return;
    var scrollTop = window.pageYOffset;
    var docHeight = document.documentElement.scrollHeight - window.innerHeight;
    var pct = docHeight > 0 ? Math.min((scrollTop / docHeight) * 100, 100) : 0;
    progressBar.style.width = pct + '%';
  }

  function updateBackToTop() {
    if (!backToTop) return;
    backToTop.classList.toggle('visible', window.pageYOffset > 600);
  }

  function updateHeader() {
    if (!header) return;
    var scroll = window.pageYOffset;
    var delta = Math.abs(scroll - lastScroll);

    if (delta < scrollThreshold) return;

    // Scrolling down past 300px — hide header
    if (scroll > 300 && scroll > lastScroll) {
      header.classList.add('header-hidden');
    } else {
      header.classList.remove('header-hidden');
    }

    // Compact when not at top — also update CSS variable so sidebar/progress adjust
    var compact = scroll > 150;
    header.classList.toggle('header-compact', compact);
    if (header.classList.contains('header-hidden')) {
      setHeaderHeight(0);
    } else {
      setHeaderHeight(compact ? COMPACT_HEIGHT : FULL_HEIGHT);
    }

    lastScroll = scroll;
  }

  function onScroll() {
    if (!ticking) {
      window.requestAnimationFrame(function() {
        updateProgress();
        updateBackToTop();
        updateHeader();
        ticking = false;
      });
      ticking = true;
    }
  }

  // Restore scroll position
  if (!location.hash) {
    var saved = parseInt(R.getSetting(SCROLL_KEY), 10);
    if (saved > 200) window.scrollTo(0, saved);
  }
  window.addEventListener('beforeunload', function() {
    R.setSetting(SCROLL_KEY, window.pageYOffset.toString());
  });

  if (backToTop) {
    backToTop.addEventListener('click', function() {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  updateProgress();
  updateBackToTop();
})();
