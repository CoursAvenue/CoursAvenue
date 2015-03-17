Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.BlocsCollection = Backbone.Collection.extend({
        model: Module.Bloc,

        url: function urlRoot () {
            var newsletter = this.newsletter;

            if (!this.newsletter.get('id')) {
                this.newsletter.save();
            }

            return Routes.pro_structure_newsletter_blocs_path(window.coursavenue.bootstrap.structure, this.newsletter.get('id'));
        },

        initialize: function initialize (models, options) {
            this.newsletter = options.newsletter;

            _.bindAll(this, 'url');
        },
    });
});
