chrome.devtools.panels.create(
    "Opal-Console",
    "assets/images/logo_128.png",
    "opal-console.html",
    function cb(panel) {
        panel.onShown.addListener(function(win){ win.focus(); });
    }
);
