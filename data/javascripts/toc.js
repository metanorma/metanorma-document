(function() {
  var sidebar = document.getElementById('toc-sidebar');
  var overlay = document.getElementById('toc-overlay');
  var hamburger = document.getElementById('toc-hamburger');
  var closeBtn = document.getElementById('toc-close-btn');
  var progressBar = document.getElementById('reading-progress');

  // --- Dark mode toggle ---
  var themeBtn = document.getElementById('theme-toggle');
  var THEME_KEY = 'metanorma-theme';

  function getSystemPreference() {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    if (themeBtn) {
      themeBtn.classList.toggle('dark', theme === 'dark');
    }
  }

  function initTheme() {
    var stored = localStorage.getItem(THEME_KEY);
    var theme = stored || getSystemPreference();
    applyTheme(theme);
  }

  if (themeBtn) {
    themeBtn.addEventListener('click', function() {
      var current = document.documentElement.getAttribute('data-theme');
      var next = current === 'dark' ? 'light' : 'dark';
      applyTheme(next);
      localStorage.setItem(THEME_KEY, next);
    });
  }
  initTheme();

  // --- Font size controls ---
  var fontDecrease = document.getElementById('font-decrease');
  var fontIncrease = document.getElementById('font-increase');
  var FONT_SIZE_KEY = 'metanorma-font-size';
  var FONT_SIZES = [0.85, 0.925, 1.0, 1.075, 1.15, 1.25];
  var DEFAULT_FONT_IDX = 2;

  function getCurrentFontIdx() {
    var stored = localStorage.getItem(FONT_SIZE_KEY);
    if (stored !== null) {
      var idx = parseInt(stored, 10);
      if (idx >= 0 && idx < FONT_SIZES.length) return idx;
    }
    return DEFAULT_FONT_IDX;
  }

  function applyFontSize(idx) {
    var scale = FONT_SIZES[idx];
    document.documentElement.style.setProperty('--reader-font-scale', scale);
    if (fontDecrease) fontDecrease.classList.toggle('disabled', idx === 0);
    if (fontIncrease) fontIncrease.classList.toggle('disabled', idx === FONT_SIZES.length - 1);
  }

  function initFontSize() {
    applyFontSize(getCurrentFontIdx());
  }

  if (fontDecrease) {
    fontDecrease.addEventListener('click', function() {
      var idx = getCurrentFontIdx();
      if (idx > 0) {
        idx--;
        localStorage.setItem(FONT_SIZE_KEY, idx);
        applyFontSize(idx);
      }
    });
  }
  if (fontIncrease) {
    fontIncrease.addEventListener('click', function() {
      var idx = getCurrentFontIdx();
      if (idx < FONT_SIZES.length - 1) {
        idx++;
        localStorage.setItem(FONT_SIZE_KEY, idx);
        applyFontSize(idx);
      }
    });
  }
  initFontSize();

  // --- Serif / Sans-serif toggle ---
  var serifBtn = document.getElementById('serif-toggle');
  var SERIF_KEY = 'metanorma-serif';

  function applySerifMode(useSerif) {
    document.documentElement.classList.toggle('reader-serif', useSerif);
    if (serifBtn) serifBtn.classList.toggle('active', useSerif);
  }

  function initSerif() {
    var stored = localStorage.getItem(SERIF_KEY);
    applySerifMode(stored === 'true');
  }

  if (serifBtn) {
    serifBtn.addEventListener('click', function() {
      var isSerif = document.documentElement.classList.contains('reader-serif');
      applySerifMode(!isSerif);
      localStorage.setItem(SERIF_KEY, !isSerif);
    });
  }
  initSerif();

  // --- ToC drawer (mobile) ---
  function openToc() {
    sidebar.classList.add('toc-open');
    overlay.classList.add('toc-overlay-active');
    document.body.style.overflow = 'hidden';
  }
  function closeToc() {
    sidebar.classList.remove('toc-open');
    overlay.classList.remove('toc-overlay-active');
    document.body.style.overflow = '';
  }
  if (hamburger) hamburger.addEventListener('click', openToc);
  if (closeBtn) closeBtn.addEventListener('click', closeToc);
  if (overlay) overlay.addEventListener('click', closeToc);

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && sidebar.classList.contains('toc-open')) closeToc();
  });

  // --- Reading progress bar ---
  function updateProgress() {
    if (!progressBar) return;
    var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    var docHeight = document.documentElement.scrollHeight - window.innerHeight;
    var pct = docHeight > 0 ? Math.min((scrollTop / docHeight) * 100, 100) : 0;
    progressBar.style.width = pct + '%';
  }

  // --- ToC active section tracking ---
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
      if (window.innerWidth < 768) closeToc();
    });
  });

  // --- Back-to-top button ---
  var backToTop = document.getElementById('back-to-top');
  if (backToTop) {
    backToTop.addEventListener('click', function() {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }
  function updateBackToTop() {
    if (!backToTop) return;
    var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    if (scrollTop > 600) {
      backToTop.classList.add('visible');
    } else {
      backToTop.classList.remove('visible');
    }
  }

  // --- Collapsible ToC sections ---
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

      // Collapse if ToC has many items
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

  // --- List of Figures / Tables toggle ---
  function initListToggles() {
    document.querySelectorAll('.toc-list-toggle').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var expanded = btn.getAttribute('aria-expanded') === 'true';
        btn.setAttribute('aria-expanded', expanded ? 'false' : 'true');
        var header = btn.parentElement;
        var listType = header.getAttribute('data-list');
        var items = document.querySelectorAll('.toc-' + listType);
        items.forEach(function(item) {
          if (expanded) {
            item.style.display = 'none';
          } else {
            item.style.display = '';
            item.style.paddingLeft = '1.2em';
          }
        });
      });
    });
  }
  initListToggles();

  // --- Reading position memory ---
  var SCROLL_KEY = 'mn-scroll-' + location.pathname;
  window.addEventListener('beforeunload', function() {
    localStorage.setItem(SCROLL_KEY, window.pageYOffset.toString());
  });
  if (!location.hash) {
    var saved = localStorage.getItem(SCROLL_KEY);
    if (saved && parseInt(saved, 10) > 200) {
      window.scrollTo(0, parseInt(saved, 10));
    }
  }

  // --- Scroll-reveal animations ---
  var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (!prefersReducedMotion && 'IntersectionObserver' in window) {
    document.documentElement.classList.add('scroll-reveal-ready');
    var revealTargets = document.querySelectorAll(
      '.doc-content > div[id], ' +
      '.doc-content > div.section-sub, ' +
      '.doc-content > div[id] > div[id], ' +
      '.doc-content > .main-section > div[id], ' +
      '.doc-content > p.doc-title'
    );

    function checkInitialVisibility() {
      revealTargets.forEach(function(el) {
        var rect = el.getBoundingClientRect();
        if (rect.top < window.innerHeight && rect.bottom > 0) {
          el.classList.add('revealed');
        }
      });
    }

    var revealObserver = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('revealed');
          revealObserver.unobserve(entry.target);
        }
      });
    }, { rootMargin: '0px 0px -40px 0px', threshold: 0.05 });

    revealTargets.forEach(function(el) {
      revealObserver.observe(el);
    });
    checkInitialVisibility();
  }

  // --- Header scroll behavior ---
  var header = document.querySelector('.doc-header');
  var lastScroll = 0;
  window.addEventListener('scroll', function() {
    if (!header) return;
    var scroll = window.pageYOffset;
    if (scroll > 200 && scroll > lastScroll) {
      header.classList.add('header-compact');
    } else {
      header.classList.remove('header-compact');
    }
    lastScroll = scroll;
  }, { passive: true });

  // --- Section arrival highlight ---
  document.querySelectorAll('.toc-link').forEach(function(link) {
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

  // --- Code copy buttons ---
  function initCodeCopy() {
    var blocks = document.querySelectorAll('.sourcecode pre');
    blocks.forEach(function(pre) {
      var wrapper = pre.parentElement;
      if (!wrapper) return;
      var btn = document.createElement('button');
      btn.className = 'code-copy-btn';
      btn.textContent = 'Copy';
      btn.setAttribute('aria-label', 'Copy code to clipboard');
      btn.addEventListener('click', function() {
        var text = pre.textContent || pre.innerText;
        if (navigator.clipboard) {
          navigator.clipboard.writeText(text).then(function() {
            btn.textContent = 'Copied!';
            btn.classList.add('copied');
            setTimeout(function() {
              btn.textContent = 'Copy';
              btn.classList.remove('copied');
            }, 2000);
          });
        } else {
          var ta = document.createElement('textarea');
          ta.value = text;
          ta.style.position = 'fixed';
          ta.style.opacity = '0';
          document.body.appendChild(ta);
          ta.select();
          document.execCommand('copy');
          document.body.removeChild(ta);
          btn.textContent = 'Copied!';
          btn.classList.add('copied');
          setTimeout(function() {
            btn.textContent = 'Copy';
            btn.classList.remove('copied');
          }, 2000);
        }
      });
      wrapper.appendChild(btn);
    });
  }
  initCodeCopy();

  // Throttled scroll listener
  var ticking = false;
  window.addEventListener('scroll', function() {
    if (!ticking) {
      window.requestAnimationFrame(function() {
        updateProgress();
        updateBackToTop();
        ticking = false;
      });
      ticking = true;
    }
  }, { passive: true });
  updateProgress();
  updateBackToTop();

  // --- Search trigger button ---
  var searchTrigger = document.getElementById('search-trigger');
  if (searchTrigger) {
    searchTrigger.addEventListener('click', function() {
      var panel = document.querySelector('.search-panel');
      if (panel) {
        panel.classList.add('search-active');
        var searchInput = panel.querySelector('.search-input');
        if (searchInput) {
          searchInput.focus();
          if (searchInput.value) searchInput.select();
        }
      }
    });
  }

  // --- Keyboard shortcuts ---
  function isEditing() {
    var el = document.activeElement;
    return el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable);
  }

  // Section navigation: collect all section headings for j/k/arrow jumping
  var sectionTargets = [];
  document.querySelectorAll('.doc-content div[id]').forEach(function(el) {
    var heading = el.querySelector('h1, h2, h3, h4');
    if (heading) sectionTargets.push(el);
  });

  function getCurrentSectionIndex() {
    var scrollMid = window.pageYOffset + window.innerHeight * 0.3;
    for (var i = 0; i < sectionTargets.length; i++) {
      var rect = sectionTargets[i].getBoundingClientRect();
      var top = rect.top + window.pageYOffset;
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
  }

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      closeToc();
      var searchPanel = document.querySelector('.search-panel');
      if (searchPanel) searchPanel.classList.remove('search-active');
      var lightbox = document.querySelector('.lightbox-overlay');
      if (lightbox) lightbox.remove();
    }

    if (isEditing()) return;

    // j or ] = next section
    if ((e.key === 'j' || e.key === ']') && sectionTargets.length > 0) {
      e.preventDefault();
      scrollToSection(getCurrentSectionIndex() + 1);
    }
    // k or [ = previous section
    if ((e.key === 'k' || e.key === '[') && sectionTargets.length > 0) {
      e.preventDefault();
      scrollToSection(getCurrentSectionIndex() - 1);
    }

    if (e.key === 't' && window.innerWidth < 768) {
      if (sidebar.classList.contains('toc-open')) {
        closeToc();
      } else {
        openToc();
      }
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

  // --- Figure lightbox ---
  document.addEventListener('click', function(e) {
    var img = e.target.closest('figure img, .doc-content img:not(.brand-logo img):not(.footer-mn-logo img)');
    if (!img) return;
    if (img.naturalWidth < 100 || img.naturalHeight < 100) return;

    var lightboxOverlay = document.createElement('div');
    lightboxOverlay.className = 'lightbox-overlay';

    var clone = document.createElement('img');
    clone.src = img.src;
    clone.alt = img.alt || '';

    lightboxOverlay.appendChild(clone);
    document.body.appendChild(lightboxOverlay);

    lightboxOverlay.addEventListener('click', function() {
      lightboxOverlay.remove();
    });
  });
})();
