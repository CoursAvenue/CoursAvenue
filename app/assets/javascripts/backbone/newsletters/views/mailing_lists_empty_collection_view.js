Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsEmptyCollectionView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_lists_empty_collection_view',

        events: {
            'change [data-import-file]':  'importFromFile',
            'click [data-import-emails]': 'importFromEmails',
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

        importFromEmails: function importContacts () {
            event.preventDefault();

            var emails     = $('[name=emails]').val();
            var structure  = window.coursavenue.bootstrap.structure;
            var newsletter = this.model.get('id');

            if (_.isEmpty(emails)) {
                COURSAVENUE.helperMethods.flash("Veuillez renseigner des adresses emails à importer.", 'error');
                return ;
            }

            var data = { emails: emails };

            var url = Routes.bulk_import_pro_structure_newsletter_mailing_lists_path(structure, newsletter)

            $.ajax(url, {
                data: data,
                type: 'POST',
                success: function (data) {
                    COURSAVENUE.helperMethods.flash(data.message, 'notice');
                },
                error: function (data) {
                    var message = data.message || "Une erreur est seurvenue lors de l'import des emails, veuillez rééssayer.";
                    COURSAVENUE.helperMethods.flash(message, 'error');
                }
            });
        },

    });
});
