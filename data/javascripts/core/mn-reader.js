// MetanormaReader — global namespace, event bus, settings
window.MetanormaReader = (function() {
  var listeners = {};

  function on(event, fn) {
    if (!listeners[event]) listeners[event] = [];
    listeners[event].push(fn);
  }

  function off(event, fn) {
    if (!listeners[event]) return;
    listeners[event] = listeners[event].filter(function(f) { return f !== fn; });
  }

  function emit(event, data) {
    if (!listeners[event]) return;
    listeners[event].forEach(function(fn) { try { fn(data); } catch(e) {} });
  }

  function getSetting(key, fallback) {
    try {
      var val = localStorage.getItem(key);
      return val !== null ? val : fallback;
    } catch (e) { return fallback; }
  }

  function setSetting(key, value) {
    try { localStorage.setItem(key, value); } catch (e) {}
  }

  return {
    on: on,
    off: off,
    emit: emit,
    getSetting: getSetting,
    setSetting: setSetting
  };
})();
