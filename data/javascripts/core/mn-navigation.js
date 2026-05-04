// Navigation: keyboard shortcuts, section jumping, reading mode
(function() {
  var R = window.MetanormaReader;
  var sectionTargets = [];

  document.querySelectorAll('.doc-content div[id]').forEach(function(el) {
    if (el.querySelector('h1, h2, h3, h4')) sectionTargets.push(el);
  });

  function getCurrentIndex() {
    var scrollMid = window.pageYOffset + window.innerHeight * 0.3;
    for (var i = 0; i < sectionTargets.length; i++) {
      var top = sectionTargets[i].getBoundingClientRect().top + window.pageYOffset;
      if (top > scrollMid) return Math.max(0, i - 1);
    }
    return sectionTargets.length - 1;
  }

  function scrollToSection(idx) {
    if (idx < 0 || idx >= sectionTargets.length) return;
    sectionTargets[idx].scrollIntoView({ behavior: 'smooth', block: 'start' });
    var heading = sectionTargets[idx].querySelector('h1, h2, h3, h4');
    if (heading) {
      heading.classList.add('section-arrival-highlight');
      setTimeout(function() { heading.classList.remove('section-arrival-highlight'); }, 1500);
    }
    R.emit('navigation:section', { index: idx, element: sectionTargets[idx] });
  }

  // Reading mode — distraction-free, narrow content
  var readingMode = false;
  var banner = document.getElementById('reading-mode-banner');
  function toggleReadingMode() {
    readingMode = !readingMode;
    document.body.classList.toggle('reading-mode', readingMode);
    var btn = document.getElementById('reading-mode-btn');
    if (btn) btn.classList.toggle('active', readingMode);
    if (banner) banner.style.display = readingMode ? 'block' : 'none';
    R.setSetting('reading-mode', readingMode.toString());
    R.emit('reading-mode', { active: readingMode });
  }

  // Restore reading mode preference
  if (R.getSetting('reading-mode') === 'true') {
    readingMode = true;
    document.body.classList.add('reading-mode');
    if (banner) banner.style.display = 'block';
    var btn = document.getElementById('reading-mode-btn');
    if (btn) btn.classList.toggle('active', true);
  }

  function isEditing() {
    var el = document.activeElement;
    return el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable);
  }

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      var lightbox = document.querySelector('.lightbox-overlay');
      if (lightbox) lightbox.remove();
    }

    if (isEditing()) return;

    if ((e.key === 'j' || e.key === ']') && sectionTargets.length > 0) {
      e.preventDefault();
      scrollToSection(getCurrentIndex() + 1);
    }
    if ((e.key === 'k' || e.key === '[') && sectionTargets.length > 0) {
      e.preventDefault();
      scrollToSection(getCurrentIndex() - 1);
    }
    if (e.key === 'r') {
      e.preventDefault();
      toggleReadingMode();
    }
    if (e.key === 'd') {
      var btn = document.getElementById('theme-toggle');
      if (btn) btn.click();
    }
  });

  R.navigation = { scrollTo: scrollToSection, getCurrentIndex: getCurrentIndex, toggleReadingMode: toggleReadingMode };
})();
