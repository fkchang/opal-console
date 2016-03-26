TOP = this;
TOP.runIt = function (js, handler){
    // alert(js);
    chrome.devtools.inspectedWindow["eval"](js, function( result, exception) {
        console.orig_log(result);
        handler(result, exception);
    });
};
