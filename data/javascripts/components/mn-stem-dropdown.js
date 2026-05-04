// Stem dropdown: hover to reveal copy buttons for math source formats
(function() {
  document.querySelectorAll('.math-container[data-stem-formats]').forEach(function(el) {
    try {
      var formats = JSON.parse(el.getAttribute('data-stem-formats'));
    } catch(e) { return; }
    if (!formats || Object.keys(formats).length === 0) return;

    var dropdown = document.createElement('div');
    dropdown.className = 'stem-dropdown';

    var label = document.createElement('div');
    label.className = 'stem-dropdown-label';
    label.textContent = 'Source format';
    dropdown.appendChild(label);

    Object.keys(formats).forEach(function(key) {
      var row = document.createElement('div');
      row.className = 'stem-dropdown-row';

      var code = document.createElement('span');
      code.textContent = formats[key];
      row.appendChild(code);

      var btn = document.createElement('button');
      btn.className = 'stem-copy-btn';
      btn.textContent = '⧉';
      btn.setAttribute('aria-label', 'Copy ' + key);
      btn.addEventListener('click', function(e) {
        e.stopPropagation();
        navigator.clipboard.writeText(formats[key]).then(function() {
          btn.textContent = '✓';
          setTimeout(function() { btn.textContent = '⧉'; }, 1200);
        });
      });
      row.appendChild(btn);
      dropdown.appendChild(row);
    });

    el.appendChild(dropdown);
  });
})();
