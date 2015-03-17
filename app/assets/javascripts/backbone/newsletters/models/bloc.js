Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bloc = Backbone.Model.extend({

        initialize: function initialize (model, options) {
            var backend_types = {
                image: 'Newsletter::Bloc::Image',
                text:  'Newsletter::Bloc::Text'
            };

            this.set('view_type', model.type);
            this.set('type', backend_types[model.type]);
        },

    });
});
