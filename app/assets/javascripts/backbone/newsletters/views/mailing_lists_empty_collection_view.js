Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsEmptyCollectionView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_lists_empty_collection_view',

        events: {
            'submit [data-import-emails]': 'importFromEmails',
            'change [data-import-file]':   'importFromFile',
        },

        initialize: function initialize (options) {
            this.model = options.model;
            _.bindAll(this, 'importFromEmails', 'importFromFile');
        },

        importFromEmails: function importContacts () {
            event.preventDefault();
            debugger
            alert('not yet implemented');
        },

        importFromFile: function importFromFile () {
            event.preventDefault();

            var structure  = window.coursavenue.bootstrap.structure;
            var newsletter = this.model.get('id');

            var file = event.srcElement.files[0];
            var data = new FormData();

            data.append('file', file);
            $.ajax({
                url:  Routes.file_import_pro_structure_newsletter_mailing_lists_path(structure, newsletter),
                data: data,
                type: 'POST',
                cache: false,
                contentType: false,
                processData: false,
                success: function (data) {
                    debugger
                },
                error: function (data) {
                    COURSAVENUE.helperMethods.flash("Erreur lors de l'import du fichier, veuillez rééssayer.", 'error');
                }
            });
        },

        chooseFileHeaders: function chooseFileHeaders () {
            debugger
        },

    });
});
