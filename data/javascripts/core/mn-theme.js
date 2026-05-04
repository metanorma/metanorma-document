// Theme: 4-mode cycle (light → sepia → dark → OLED), font size, serif toggle, reading mode
(function() {
  var R = window.MetanormaReader;
  var themeBtn = document.getElementById('theme-toggle');
  var KEY = 'metanorma-theme';
  var MODES = ['light', 'sepia', 'dark', 'oled'];

  function apply(mode) {
    document.documentElement.setAttribute('data-theme', mode);
    if (themeBtn) {
      themeBtn.className = 'reader-btn theme-toggle mode-' + mode;
    }
    R.emit('theme:change', { theme: mode });
  }

  function init() {
    var stored = R.getSetting(KEY);
    var mode = stored && MODES.indexOf(stored) >= 0 ? stored : getSystemPreference();
    apply(mode);
  }

  function getSystemPreference() {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function nextMode() {
    var current = document.documentElement.getAttribute('data-theme') || 'light';
    var idx = MODES.indexOf(current);
    return MODES[(idx + 1) % MODES.length];
  }

  if (themeBtn) {
    themeBtn.addEventListener('click', function() {
      var next = nextMode();
      apply(next);
      R.setSetting(KEY, next);
    });
  }

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
    if (!R.getSetting(KEY)) apply(e.matches ? 'dark' : 'light');
  });

  init();

  // Font size
  var FONT_KEY = 'metanorma-font-size';
  var FONT_SIZES = [0.85, 0.925, 1.0, 1.075, 1.15, 1.25];
  var DEFAULT_IDX = 2;
  var fontDecrease = document.getElementById('font-decrease');
  var fontIncrease = document.getElementById('font-increase');

  function applyFontSize(idx) {
    document.documentElement.style.setProperty('--reader-font-scale', FONT_SIZES[idx]);
    if (fontDecrease) fontDecrease.classList.toggle('disabled', idx === 0);
    if (fontIncrease) fontIncrease.classList.toggle('disabled', idx === FONT_SIZES.length - 1);
  }

  function getCurrentFontIdx() {
    var stored = R.getSetting(FONT_KEY);
    if (stored !== null) {
      var idx = parseInt(stored, 10);
      if (idx >= 0 && idx < FONT_SIZES.length) return idx;
    }
    return DEFAULT_IDX;
  }

  if (fontDecrease) fontDecrease.addEventListener('click', function() {
    var idx = getCurrentFontIdx();
    if (idx > 0) { idx--; R.setSetting(FONT_KEY, idx); applyFontSize(idx); }
  });
  if (fontIncrease) fontIncrease.addEventListener('click', function() {
    var idx = getCurrentFontIdx();
    if (idx < FONT_SIZES.length - 1) { idx++; R.setSetting(FONT_KEY, idx); applyFontSize(idx); }
  });
  applyFontSize(getCurrentFontIdx());

  // Serif toggle
  var serifBtn = document.getElementById('serif-toggle');
  var SERIF_KEY = 'metanorma-serif';

  function applySerifMode(useSerif) {
    document.documentElement.classList.toggle('reader-serif', useSerif);
    if (serifBtn) serifBtn.classList.toggle('active', useSerif);
  }

  if (serifBtn) serifBtn.addEventListener('click', function() {
    var isSerif = document.documentElement.classList.contains('reader-serif');
    applySerifMode(!isSerif);
    R.setSetting(SERIF_KEY, (!isSerif).toString());
  });
  applySerifMode(R.getSetting(SERIF_KEY) === 'true');

  // Reading mode button
  var readingBtn = document.getElementById('reading-mode-btn');
  if (readingBtn) {
    readingBtn.addEventListener('click', function() {
      if (R.navigation && R.navigation.toggleReadingMode) {
        R.navigation.toggleReadingMode();
      }
    });
  }

  // Exit reading mode button
  var exitBtn = document.getElementById('exit-reading-btn');
  if (exitBtn) {
    exitBtn.addEventListener('click', function() {
      if (R.navigation && R.navigation.toggleReadingMode) {
        R.navigation.toggleReadingMode();
      }
    });
  }

  // Settings dropdown toggle
  var settingsToggle = document.getElementById('settings-toggle');
  var settingsDropdown = document.getElementById('settings-dropdown');
  if (settingsToggle && settingsDropdown) {
    settingsToggle.addEventListener('click', function(e) {
      e.stopPropagation();
      settingsDropdown.classList.toggle('open');
    });
    document.addEventListener('click', function(e) {
      if (!settingsDropdown.contains(e.target)) {
        settingsDropdown.classList.remove('open');
      }
    });
  }

  // Cover title → header animation
  var headerTitle = document.getElementById('header-doc-title');
  var coverSection = document.querySelector('.title-section');
  if (headerTitle && coverSection && 'IntersectionObserver' in window) {
    var coverObserver = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        headerTitle.classList.toggle('visible', !entry.isIntersecting);
      });
    }, { threshold: 0.1 });
    coverObserver.observe(coverSection);
  }
})();
