TOP = this;
TOP.runIt = function (js, handler){
    console.orig_log(js);
    chrome.devtools.inspectedWindow["eval"](js, function( result, exception) {
        console.orig_log(result);
        handler(result, exception);
    });

};
