// Create a connection to the background page
var backgroundPageConnection = chrome.runtime.connect({
    name: 'panel'
});

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
    // chrome.devtools.inspectedWindow.getResources(function(stuff) {console.log(stuff);});
}


backgroundPageConnection.postMessage({
    name: 'init',
    tabId: chrome.devtools.inspectedWindow.tabId
});


backgroundPageConnection.onMessage.addListener(function(msg) {
    if(msg.eventType == "inject-opal-console-hooks") {
        // run this everytime the page is refreshed
        injectChromeEval();
        // alert('inject that mother');
    }
    // alert('backgroundPageConnection msg = ' + JSON.stringify(msg));
});

// run it the 1st time it's loaded
injectChromeEval();
