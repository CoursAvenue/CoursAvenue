Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NewsletterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'newsletter_view',

        updateLayout: function updateLayout (data) {
            var model = data.model;
            this.model.set({ layout_id: model.get('id') });

            this.render();
        },
    });
});

