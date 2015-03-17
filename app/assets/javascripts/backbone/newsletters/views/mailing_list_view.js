Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_view',
        tagName: 'div',

        events: {
            'click [data-import]': 'importList',
        },

        initialize: function initialize () {
            _.bindAll(this, 'saveModel', 'importList');
        },

        saveModel: function saveModel () {
        },

        // When the user wants to import its mailing list.
        importList: function importList () {
            this.model.save();
            var path = Routes.new_pro_structure_user_profile_import_path(window.coursavenue.bootstrap.structure);

            window.location = path;
        },

    });
});
