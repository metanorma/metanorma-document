// Glossary panel: reads structured data from server-rendered data attributes
(function() {
  var R = window.MetanormaReader;
  var panel = null;
  var terms = [];

  function collectTerms() {
    if (terms.length > 0) return terms;
    document.querySelectorAll('[data-term-name]').forEach(function(el) {
      var name = el.getAttribute('data-term-name');
      var def = el.getAttribute('data-term-definition') || '';
      var id = el.id;
      if (name) {
        terms.push({ id: id, name: name, definition: def });
      }
    });
    return terms;
  }

  function buildPanel() {
    if (panel) return panel;
    collectTerms();
    panel = document.createElement('div');
    panel.className = 'glossary-panel';
    panel.setAttribute('role', 'dialog');
    panel.setAttribute('aria-label', 'Glossary');

    var html = '<div class="glossary-inner">';
    html += '<div class="glossary-header">';
    html += '<span class="glossary-title">Glossary</span>';
    html += '<span class="glossary-count">' + terms.length + ' terms</span>';
    html += '<button class="glossary-close" aria-label="Close">&times;</button>';
    html += '</div>';
    html += '<input class="glossary-search" id="glossary-search" placeholder="Filter terms..." />';
    html += '<div class="glossary-list">';
    terms.forEach(function(t) {
      html += '<div class="glossary-entry" data-term="' + t.name.toLowerCase() + '">';
      html += '<a href="#' + t.id + '" class="glossary-term">' + t.name + '</a>';
      if (t.definition) html += '<p class="glossary-def">' + t.definition + '</p>';
      html += '</div>';
    });
    html += '</div></div>';
    panel.innerHTML = html;
    document.body.appendChild(panel);

    panel.querySelector('.glossary-close').addEventListener('click', close);

    var search = panel.querySelector('.glossary-search');
    search.addEventListener('input', function() {
      var q = this.value.toLowerCase();
      panel.querySelectorAll('.glossary-entry').forEach(function(el) {
        el.style.display = el.getAttribute('data-term').indexOf(q) >= 0 ? '' : 'none';
      });
    });

    panel.addEventListener('click', function(e) {
      if (e.target === panel) close();
    });

    return panel;
  }

  function open() {
    buildPanel();
    panel.classList.add('glossary-visible');
    var search = panel.querySelector('.glossary-search');
    if (search) setTimeout(function() { search.focus(); }, 100);
  }

  function close() {
    if (panel) panel.classList.remove('glossary-visible');
  }

  function toggle() {
    if (panel && panel.classList.contains('glossary-visible')) {
      close();
    } else {
      open();
    }
  }

  var glossaryBtn = document.getElementById('glossary-btn');
  if (glossaryBtn) {
    glossaryBtn.addEventListener('click', function(e) {
      e.preventDefault();
      toggle();
    });
  }

  document.addEventListener('keydown', function(e) {
    var el = document.activeElement;
    if (el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable)) return;
    if (e.key === 'g' && !e.ctrlKey && !e.metaKey) {
      e.preventDefault();
      toggle();
    }
    if (e.key === 'Escape' && panel && panel.classList.contains('glossary-visible')) {
      close();
    }
  });

  R.glossary = { open: open, close: close, toggle: toggle, terms: terms };
})();
