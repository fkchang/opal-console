var panelCreated = false;

function createPanelIfOpalLoaded() {
    if (panelCreated) {
        return;
    }
    chrome.devtools.inspectedWindow.eval(`!! window.Opal`, function(pageHasOpal, err) {
        if (!pageHasOpal || panelCreated) {
            return;
        }

        clearInterval(loadCheckInterval);
        panelCreated = true;
        chrome.devtools.panels.create(
            "Opal-Console",
            "assets/images/logo_128.png",
            "opal-console.html",
            function cb(panel) {
                panel.onShown.addListener(function(win){ win.focus(); });
            }
        );
    });
}

chrome.devtools.network.onNavigated.addListener(function() {
    createPanelIfOpalLoaded();
});

// Check to see if Opal has loaded once per second in case Opal is added
// after page load
var loadCheckInterval = setInterval(function() {
    createPanelIfOpalLoaded();
}, 1000);

createPanelIfOpalLoaded();

