chrome.devtools.panels.create(
    "Opal-Console",
    "assets/images/logo_128.png",
    "opal-console.html",
    function cb(panel) {
        panel.onShown.addListener(function(win){ win.focus(); });
    }
);
// we need to inject something that returns useful inspects because serialization
// between inspectedWindow and devtools is limited
