// Keyboard shortcuts panel (? key or button)
(function() {
  var R = window.MetanormaReader;
  var panel = null;

  var shortcuts = [
    { key: '/', desc: 'Search' },
    { key: 'j / ]', desc: 'Next section' },
    { key: 'k / [', desc: 'Previous section' },
    { key: 't', desc: 'Toggle table of contents (mobile)' },
    { key: 'g', desc: 'Glossary' },
    { key: 'r', desc: 'Reading mode' },
    { key: 'd', desc: 'Cycle theme (light/sepia/dark/OLED)' },
    { key: 'Escape', desc: 'Close panel' },
    { key: '?', desc: 'This help' }
  ];

  function buildPanel() {
    if (panel) return panel;
    panel = document.createElement('div');
    panel.className = 'shortcuts-panel';
    panel.setAttribute('role', 'dialog');
    panel.setAttribute('aria-label', 'Keyboard shortcuts');

    var html = '<div class="shortcuts-inner">';
    html += '<div class="shortcuts-title">Keyboard Shortcuts</div><div class="shortcuts-list">';
    shortcuts.forEach(function(s) {
      html += '<div class="shortcuts-row">';
      html += '<kbd>' + s.key.replace(/ /g, '</kbd> <kbd>') + '</kbd>';
      html += '<span class="shortcuts-desc">' + s.desc + '</span>';
      html += '</div>';
    });
    html += '</div></div>';
    panel.innerHTML = html;
    document.body.appendChild(panel);

    panel.addEventListener('click', function(e) {
      if (e.target === panel) close();
    });
    return panel;
  }

  function open() {
    buildPanel();
    panel.classList.add('shortcuts-visible');
  }

  function close() {
    if (panel) panel.classList.remove('shortcuts-visible');
  }

  function toggle() {
    if (panel && panel.classList.contains('shortcuts-visible')) {
      close();
    } else {
      open();
    }
  }

  // Wire up the header button
  var shortcutsBtn = document.getElementById('shortcuts-btn');
  if (shortcutsBtn) {
    shortcutsBtn.addEventListener('click', function(e) {
      e.preventDefault();
      toggle();
    });
  }

  document.addEventListener('keydown', function(e) {
    var el = document.activeElement;
    if (el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable)) return;

    if (e.key === '?') {
      e.preventDefault();
      toggle();
    }
    if (e.key === 'Escape' && panel && panel.classList.contains('shortcuts-visible')) {
      close();
    }
  });

  R.shortcuts = { open: open, close: close, toggle: toggle };
})();
