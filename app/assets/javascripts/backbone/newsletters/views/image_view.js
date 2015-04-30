Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.ImageView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'image_view',
        className: 'inline-block v-top push-half--bottom opacity-50 fade-in-on-hover cursor-pointer',
        events: {
            'click': 'selected'
        },

        selected: function selected () {
            this.trigger('selected', this.model);
        }
    });

});
