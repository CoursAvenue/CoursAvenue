Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingList = Backbone.Model.extend({
        urlRoot: function urlRoot () {
            var newsletter = this.get('newsletter')
            var structure  = window.coursavenue.bootstrap.structure;

            if (newsletter.isNew()) {
                newsletter.save();
            }

            return Routes.pro_structure_newsletter_mailing_lists_path(structure, newsletter.get('id'));
        },

        initialize: function initialize (model, options) {
            _.bindAll(this, 'urlRoot');
        },
    });
});
