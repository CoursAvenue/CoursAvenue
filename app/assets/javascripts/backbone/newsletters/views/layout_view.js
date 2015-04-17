Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.LayoutView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'layout_view',
        tagName: 'div',
        className: 'inline-block palm-one-while push--right',

        events: {
            'click [data-layout]'  : 'selectLayout',
        },

        initialize: function initialize () {
            _.bindAll(this, 'selectLayout');
        },

        selectLayout: function selectLayout () {
            this.trigger('selected', { model: this.model });
        },
    });
});
