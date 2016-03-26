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
var injectChromeEval = function() {
    // load injected script
    var xhr = new XMLHttpRequest();
    xhr.open('GET', chrome.extension.getURL('/chrome-injection.js'), false);
    xhr.send();

    var script = xhr.responseText;

    // inject into inspectedWindow
    chrome.devtools.inspectedWindow.eval(script);
}
injectChromeEval();
