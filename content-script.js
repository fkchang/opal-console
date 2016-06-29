// setup communication

// proxy from main page to devtools (via the background page)
var port = chrome.runtime.connect({
    name: 'content-script',
});

var injectOpalConsoleEvalMsg = {
    source: "opal-console-content-script",
    eventType: "inject-opal-console-hooks"
};

chrome.runtime.sendMessage( injectOpalConsoleEvalMsg );

window.addEventListener('message', function(event) {
    console.log('content listener');
    console.log(event);
    // Only accept messages from same frame
    if (event.source !== window) {
        return;
    }

    var message = event.data;

    // Only accept messages that we know are ours
    if (typeof message !== 'object' || message === null || !message.hello) {
        return;
    }

    chrome.runtime.sendMessage(message);
});
