// Footnotes: click-to-scroll from inline markers, slide-up pane on hover
(function() {
  var pane = document.getElementById('fn-annotation-pane');
  var paneLabel = document.getElementById('fn-annotation-label');
  var paneContent = document.getElementById('fn-annotation-content');
  if (!pane) return;

  var hideTimeout;

  function showPane(label, html) {
    clearTimeout(hideTimeout);
    paneLabel.textContent = label;
    paneContent.innerHTML = html;
    pane.classList.add('visible');
  }

  function scheduleHide() {
    hideTimeout = setTimeout(function() {
      pane.classList.remove('visible');
    }, 300);
  }

  document.addEventListener('click', function(e) {
    var link = e.target.closest('.fn-link');
    if (!link) return;
    var href = link.getAttribute('data-href');
    if (!href) return;
    var target = document.querySelector(href);
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'center' });
      target.classList.add('footnote-arrival');
      setTimeout(function() { target.classList.remove('footnote-arrival'); }, 1500);
    }
  });

  document.addEventListener('keydown', function(e) {
    var link = e.target.closest('.fn-link');
    if (!link) return;
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      link.click();
    }
  });

  document.addEventListener('mouseenter', function(e) {
    var marker = e.target.closest('.fn-marker');
    if (!marker) return;
    var popup = marker.querySelector('.fn-popup');
    var link = marker.querySelector('.fn-link');
    if (!popup || !link) return;
    showPane(link.textContent, popup.innerHTML);
  }, true);

  document.addEventListener('mouseleave', function(e) {
    var marker = e.target.closest('.fn-marker');
    if (!marker) return;
    scheduleHide();
  }, true);

  pane.addEventListener('mouseenter', function() {
    clearTimeout(hideTimeout);
  });

  pane.addEventListener('mouseleave', function() {
    scheduleHide();
  });
})();