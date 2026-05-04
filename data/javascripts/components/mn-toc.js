// ToC: sidebar drawer, active tracking, collapsible sections, list toggles
(function() {
  var R = window.MetanormaReader;
  var sidebar = document.getElementById('toc-sidebar');
  var overlay = document.getElementById('toc-overlay');
  var hamburger = document.getElementById('toc-hamburger');
  var closeBtn = document.getElementById('toc-close-btn');
  if (!sidebar) return;

  // --- Drawer ---
  function open() {
    sidebar.classList.add('toc-open');
    overlay.classList.add('toc-overlay-active');
    document.body.style.overflow = 'hidden';
    R.emit('toc:open');
  }

  function close() {
    sidebar.classList.remove('toc-open');
    overlay.classList.remove('toc-overlay-active');
    document.body.style.overflow = '';
    R.emit('toc:close');
  }

  if (hamburger) hamburger.addEventListener('click', open);
  if (closeBtn) closeBtn.addEventListener('click', close);
  if (overlay) overlay.addEventListener('click', close);

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && sidebar.classList.contains('toc-open')) close();
  });

  // --- Active section tracking ---
  var tocLinks = document.querySelectorAll('.toc-link');
  var sections = [];
  tocLinks.forEach(function(link) {
    var target = document.getElementById(link.getAttribute('data-target'));
    if (target) sections.push({ el: target, link: link });
  });

  if (sections.length > 0 && 'IntersectionObserver' in window) {
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          tocLinks.forEach(function(l) { l.classList.remove('toc-active'); });
          var match = sections.find(function(s) { return s.el === entry.target; });
          if (match) {
            match.link.classList.add('toc-active');
            if (match.link.scrollIntoViewIfNeeded) {
              match.link.scrollIntoViewIfNeeded(false);
            }
          }
        }
      });
    }, { rootMargin: '-80px 0px -60% 0px' });
    sections.forEach(function(s) { observer.observe(s.el); });
  }

  // Close sidebar on ToC link click (mobile)
  tocLinks.forEach(function(link) {
    link.addEventListener('click', function() {
      if (window.innerWidth < 768) close();
    });
  });

  // --- Section arrival highlight ---
  tocLinks.forEach(function(link) {
    link.addEventListener('click', function() {
      var targetId = link.getAttribute('data-target');
      var target = document.getElementById(targetId);
      if (!target) return;
      var heading = target.querySelector('h1, h2, h3, h4');
      if (heading) {
        heading.classList.add('section-arrival-highlight');
        setTimeout(function() { heading.classList.remove('section-arrival-highlight'); }, 1500);
      }
    });
  });

  // --- Collapsible ToC ---
  function initCollapsibleToc() {
    var tocItems = document.querySelectorAll('.toc-level-1 > li');
    tocItems.forEach(function(li) {
      var children = li.querySelectorAll('.toc-level-2, .toc-level-3');
      if (children.length === 0) return;

      var link = li.querySelector('.toc-link');
      if (!link) return;

      var toggle = document.createElement('button');
      toggle.className = 'toc-toggle';
      toggle.setAttribute('aria-label', 'Toggle subsections');
      toggle.setAttribute('aria-expanded', 'false');
      toggle.innerHTML = '&#9656;';
      link.insertBefore(toggle, link.firstChild);

      if (tocItems.length > 10) {
        children.forEach(function(c) { c.style.display = 'none'; });
      } else {
        toggle.setAttribute('aria-expanded', 'true');
        toggle.innerHTML = '&#9662;';
      }

      toggle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var expanded = toggle.getAttribute('aria-expanded') === 'true';
        toggle.setAttribute('aria-expanded', expanded ? 'false' : 'true');
        toggle.innerHTML = expanded ? '&#9656;' : '&#9662;';
        children.forEach(function(c) { c.style.display = expanded ? 'none' : ''; });
      });
    });
  }
  initCollapsibleToc();

  // --- List of Figures/Tables toggles ---
  function initListToggles() {
    document.querySelectorAll('.toc-list-toggle').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var expanded = btn.getAttribute('aria-expanded') === 'true';
        btn.setAttribute('aria-expanded', expanded ? 'false' : 'true');
        var header = btn.parentElement;
        var listType = header.getAttribute('data-list');
        document.querySelectorAll('.toc-' + listType).forEach(function(item) {
          item.style.display = expanded ? 'none' : '';
        });
      });
    });
  }
  initListToggles();

  // --- Mobile keyboard toggle ---
  function isEditing() {
    var el = document.activeElement;
    return el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable);
  }
  document.addEventListener('keydown', function(e) {
    if (isEditing()) return;
    if (e.key === 't' && window.innerWidth < 768) {
      sidebar.classList.contains('toc-open') ? close() : open();
    }
  });

  // --- Reading time estimate ---
  var docContent = document.getElementById('doc-content');
  if (docContent) {
    var text = docContent.textContent || docContent.innerText || '';
    var words = text.trim().split(/\s+/).length;
    var minutes = Math.max(1, Math.round(words / 200));
    var tocHeading = document.querySelector('.toc-heading');
    if (tocHeading) {
      var badge = document.createElement('span');
      badge.className = 'reading-time';
      badge.textContent = minutes + ' min read';
      tocHeading.appendChild(document.createTextNode(' '));
      tocHeading.appendChild(badge);
    }
  }

  // Public API
  R.toc = { open: open, close: close };

  // --- Touch swipe for ToC (mobile) ---
  var touchStartX = 0;
  var touchStartY = 0;
  document.addEventListener('touchstart', function(e) {
    touchStartX = e.touches[0].clientX;
    touchStartY = e.touches[0].clientY;
  }, { passive: true });
  document.addEventListener('touchend', function(e) {
    var dx = e.changedTouches[0].clientX - touchStartX;
    var dy = Math.abs(e.changedTouches[0].clientY - touchStartY);
    if (dy > 50) return; // vertical scroll, ignore
    if (touchStartX < 30 && dx > 80) {
      open(); // swipe right from left edge
    } else if (dx < -80 && sidebar.classList.contains('toc-open')) {
      close(); // swipe left to close
    }
  }, { passive: true });
})();
