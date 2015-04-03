Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bloc = Backbone.Model.extend({

        urlRoot: function urlRoot () {
            var newsletter = this.get('newsletter');
            var structure  = window.coursavenue.bootstrap.structure;
            var multiBloc  = this.collection.multiBloc;

            if (newsletter.isNew()) {
                newsletter.save();
            }

            if (multiBloc) {
                return Routes.sub_bloc_create_pro_structure_newsletter_bloc_path(structure, newsletter.get('id'), multiBloc.get('id'));
            } else {
                return Routes.pro_structure_newsletter_blocs_path(structure, newsletter.get('id'));
            }
        },

        initialize: function initialize (model, options) {
            if (!this.has('view_type')) {
                this.setViewTypes(model);
            }

            _.bindAll(this, 'urlRoot', 'setViewTypes');
        },

        setViewTypes: function setViewTypes (model) {
            var backend_types = {
                image: 'Newsletter::Bloc::Image',
                text:  'Newsletter::Bloc::Text',
                multi: 'Newsletter::Bloc::Multi'
            };

            this.set('view_type', model.type);
            this.set('type', backend_types[model.type]);
        },

    });
});
