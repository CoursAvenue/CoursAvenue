Backbone.Marionette.Renderer.render = function(template, data){
    if (template === "") return "";
    if (!JST[template]) throw "Template '" + template + "' not found!";
    return JST[template](data);
}
