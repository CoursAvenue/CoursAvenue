Newsletter.module('Views.Blocs', function(Module, App, Backbone, Marionette, $, _) {
    Module.Multi = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'multi',
        tagName: 'div',
        childViewContainer: '[data-type=sub-blocs]',

        initialize: function initialize () {
        },

        getChildView: function getChildView (item) {
        },
    });
});
