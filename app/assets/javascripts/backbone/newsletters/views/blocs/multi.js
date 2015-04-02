Newsletter.module('Views.Blocs', function(Module, App, Backbone, Marionette, $, _) {
    Module.Multi = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'multi',
        tagName: 'div',
});
