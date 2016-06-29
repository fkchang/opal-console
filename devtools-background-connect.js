// Create a connection to the background page
var backgroundPageConnection = chrome.runtime.connect({
    name: 'panel'
});

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

backgroundPageConnection.postMessage({
    name: 'fuck me',
    tabId: chrome.devtools.inspectedWindow.tabId
});

window.postMessage( {
    data: { msg: 'Ima let u finish'},
}, "*");

backgroundPageConnection.onMessage.addListener(function(msg) {
    if(msg.eventType == "inject-opal-console-hooks") {
        injectChromeEval();
        alert('inject that mother');
    }
    alert('backgroundPageConnection msg = ' + JSON.stringify(msg));
});


