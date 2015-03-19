Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bloc = Backbone.Model.extend({

        urlRoot: function urlRoot () {
            var newsletter = this.get('newsletter');

            if (newsletter.isNew()) {
                newsletter.save();
            }

            return Routes.pro_structure_newsletter_blocs_path(window.coursavenue.bootstrap.structure, newsletter.get('id'));
        },

        initialize: function initialize (model, options) {
            if (!this.has('view_type')) {
                var backend_types = {
                    image: 'Newsletter::Bloc::Image',
                    text:  'Newsletter::Bloc::Text'
                };

                this.set('view_type', model.type);
                this.set('type', backend_types[model.type]);
            }
            _.bindAll(this, 'urlRoot');
        },

    });
});
