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
                return Routes.pro_structure_newsletter_bloc_sub_blocs_path(structure, newsletter.get('id'), multiBloc.get('id'));
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

        // For some reason, when updating, some attributes are not namespaced into `bloc`,
        // and are therefore not found by Rails strong parameters. This fixes that by manually
        // generating the JSON sent to the server.
        toJSON: function toJSON () {
            var serialized_new_attributes        = _.clone(this.attributes);
            serialized_new_attributes.newsletter = null; // We do not need newsletter attributes
            return { bloc: serialized_new_attributes }
        }

    });
});
