// Search: in-page text search with highlighting (unchanged from search.js)
(function() {
  var panel, input, counter, content;
  var matches = [], currentIndex = -1;
  var isOpen = false;

  function init() {
    content = document.getElementById('doc-content');
    if (!content) return;
    createPanel();
    bindKeys();
  }

  function createPanel() {
    panel = document.createElement('div');
    panel.className = 'search-panel';
    panel.id = 'search-panel';
    panel.setAttribute('role', 'search');
    panel.innerHTML =
      '<svg class="search-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">' +
      '<circle cx="6.5" cy="6.5" r="5"/><line x1="10.2" y1="10.2" x2="14.5" y2="14.5"/></svg>' +
      '<input type="text" id="search-input" class="search-input" placeholder="Search\u2026" autocomplete="off" spellcheck="false" />' +
      '<span class="search-counter" id="search-counter"></span>' +
      '<button class="search-btn" id="search-prev" title="Previous (Shift+Enter)" aria-label="Previous match">' +
      '<svg viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="9,8 6,4 3,8"/></svg></button>' +
      '<button class="search-btn" id="search-next" title="Next (Enter)" aria-label="Next match">' +
      '<svg viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="3,4 6,8 9,4"/></svg></button>' +
      '<button class="search-btn search-close" id="search-close" title="Close (Escape)" aria-label="Close search">&times;</button>';
    document.body.appendChild(panel);

    input = document.getElementById('search-input');
    counter = document.getElementById('search-counter');

    input.addEventListener('input', debounce(function() {
      performSearch(input.value);
    }, 180));

    input.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        navigate(e.shiftKey ? -1 : 1);
      }
    });

    document.getElementById('search-prev').addEventListener('click', function() { navigate(-1); });
    document.getElementById('search-next').addEventListener('click', function() { navigate(1); });
    document.getElementById('search-close').addEventListener('click', close);
  }

  function debounce(fn, ms) {
    var timer;
    return function() {
      clearTimeout(timer);
      timer = setTimeout(fn, ms);
    };
  }

  function bindKeys() {
    document.addEventListener('keydown', function(e) {
      if ((e.ctrlKey && e.shiftKey && (e.key === 'F' || e.key === 'f')) ||
          (e.key === '/' && !isEditable(e.target))) {
        e.preventDefault();
        open();
      }
      if (e.key === 'Escape' && isOpen) {
        e.preventDefault();
        close();
      }
    });
  }

  function isEditable(el) {
    return el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable;
  }

  function open() {
    isOpen = true;
    panel.classList.add('search-active');
    input.focus();
    if (input.value) input.select();
  }

  function close() {
    isOpen = false;
    panel.classList.remove('search-active');
    clearHighlights();
    input.value = '';
    counter.textContent = '';
    matches = [];
    currentIndex = -1;
  }

  function performSearch(query) {
    clearHighlights();
    if (!query || query.length < 2) {
      counter.textContent = '';
      matches = [];
      currentIndex = -1;
      return;
    }

    highlightMatches(query);
    matches = Array.from(content.querySelectorAll('mark.search-match'));

    if (matches.length > 0) {
      currentIndex = 0;
      scrollToMatch(0);
    } else {
      currentIndex = -1;
    }
    updateCounter();
  }

  function highlightMatches(query) {
    var walker = document.createTreeWalker(content, NodeFilter.SHOW_TEXT, {
      acceptNode: function(node) {
        var p = node.parentNode;
        if (!p) return NodeFilter.FILTER_REJECT;
        var tag = p.tagName;
        if (tag === 'SCRIPT' || tag === 'STYLE' || tag === 'NOSCRIPT') return NodeFilter.FILTER_REJECT;
        if (tag === 'MARK' && p.classList.contains('search-match')) return NodeFilter.FILTER_REJECT;
        if (tag === 'MARK' && p.classList.contains('search-current')) return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    });

    var textNodes = [];
    while (walker.nextNode()) textNodes.push(walker.currentNode);

    var escaped = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    var regex = new RegExp('(' + escaped + ')', 'gi');

    textNodes.forEach(function(textNode) {
      var text = textNode.textContent;
      if (!regex.test(text)) return;
      regex.lastIndex = 0;

      var fragment = document.createDocumentFragment();
      var lastIdx = 0;
      var match;

      while ((match = regex.exec(text)) !== null) {
        if (match.index > lastIdx) {
          fragment.appendChild(document.createTextNode(text.substring(lastIdx, match.index)));
        }
        var mark = document.createElement('mark');
        mark.className = 'search-match';
        mark.textContent = match[1];
        fragment.appendChild(mark);
        lastIdx = regex.lastIndex;
      }

      if (lastIdx < text.length) {
        fragment.appendChild(document.createTextNode(text.substring(lastIdx)));
      }

      textNode.parentNode.replaceChild(fragment, textNode);
    });
  }

  function clearHighlights() {
    content.querySelectorAll('mark.search-match, mark.search-current').forEach(function(mark) {
      var parent = mark.parentNode;
      parent.replaceChild(document.createTextNode(mark.textContent), mark);
      parent.normalize();
    });
  }

  function navigate(direction) {
    if (matches.length === 0) return;

    if (currentIndex >= 0 && currentIndex < matches.length) {
      matches[currentIndex].classList.remove('search-current');
    }

    currentIndex += direction;
    if (currentIndex >= matches.length) currentIndex = 0;
    if (currentIndex < 0) currentIndex = matches.length - 1;

    scrollToMatch(currentIndex);
    updateCounter();
  }

  function scrollToMatch(index) {
    if (index < 0 || index >= matches.length) return;
    var mark = matches[index];
    mark.classList.add('search-current');
    mark.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  function updateCounter() {
    if (matches.length === 0) {
      counter.textContent = currentIndex === -1 ? '' : 'No matches';
    } else {
      counter.textContent = (currentIndex + 1) + ' / ' + matches.length;
    }
  }

  // Search trigger button in header
  var searchTrigger = document.getElementById('search-trigger');
  if (searchTrigger) {
    searchTrigger.addEventListener('click', function() {
      if (panel) open();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
