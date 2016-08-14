var Action = function() {};

Action.prototype = {
    
run: function(parameters) {
    // signal that JavaScript has finished preprocessing and pass a dictionary to the extension
    parameters.completionFunction({"URL": document.URL, "title": document.title });
},

    // this method is invoked after ActionViewController.done()
finalize: function(parameters) {
    // extract the "customJavaScript" value out of the parameters array
    var customJavaScript = parameters["customJavaScript"];
    // execute the code in customJavaScript
    eval(customJavaScript);
}
    
};

var ExtensionPreprocessingJS = new Action