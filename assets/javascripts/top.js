TOP = this;
TOP.runIt = function (js, handler){
    console.orig_log(js);
    chrome.devtools.inspectedWindow["eval"](js, function( result, exception) {
        console.orig_log("Result");
        console.orig_log(result);
        console.orig_log("Exeption");
        console.orig_log(exception);
        handler(result, exception);
    });

};
