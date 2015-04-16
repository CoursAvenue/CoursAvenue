Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListImportView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_import_view',

        events: {
            'click [data-behavior=show-import-options]' : 'showImportOptions',
            'change [data-import-file]'                 : 'importFromFile',
            'click [data-import-emails]'                : 'importFromEmails',
            'submit'                                    : 'chooseFileHeaders',
            'click [data-popup]'                        : 'chooseFileHeaders'
        },

        ui: {
            '$import_options'          : '[data-type=import-options]',
            '$show_more_options_button': '[data-behavior=show-import-options]'
        },

        initialize: function initialize (options) {
            this.model = options.model;
            _.bindAll(this, 'importFromFile', 'chooseFileHeaders', 'importFromEmails');
        },

        showImportOptions: function showImportOptions (options) {
            this.ui.$show_more_options_button.slideUp();
            this.ui.$import_options.slideDown();
        },

        importFromFile: function importFromFile () {
            event.preventDefault();

            var structure  = window.coursavenue.bootstrap.structure;
            var newsletter = this.model.get('id');

            var file = event.srcElement.files[0];
            var data = new FormData();

            if (!file) {
                COURSAVENUE.helperMethods.flash("Veuillez séléctionner un fichier.", 'error');
                return ;
            }

            data.append('file', file);
            var url = Routes.file_import_pro_structure_newsletter_mailing_lists_path(structure, newsletter);
            $.ajax(url, {
                data: data,
                type: 'POST',
                cache: false,
                contentType: false,
                processData: false,
                success: function success (data) {
                    $.fancybox.open(data.popup_to_show);
                }.bind(this),
                error: function error (data) {
                    COURSAVENUE.helperMethods.flash("Erreur lors de l'import du fichier, veuillez rééssayer.", 'error');
                }
            });
        },

        chooseFileHeaders: function chooseFileHeaders () {
            event.preventDefault();

            var structure  = window.coursavenue.bootstrap.structure;
            var newsletter = this.model.get('id');

            var form = $('form[data-header]');
            var data = form.serialize();
            var url  = Routes.update_headers_pro_structure_newsletter_mailing_lists_path(structure, newsletter, { user_profile_import: this.user_profile_import });

            $.ajax(url, {
                data: data,
                type: 'POST',
                success: function success (data) {
                    var mailing_list = new Newsletter.Models.MailingList(data.mailing_list);
                    COURSAVENUE.helperMethods.flash(data.message, 'notice');
                    this.collection.add(mailing_list);
                    mailing_list.set('selected', true);
                }.bind(this),
                error: function error (data) {
                    var message = data.message || "Erreur lors de l'association des colonnes, veuillez rééssayer.";
                    COURSAVENUE.helperMethods.flash(message, 'error');
                }
            });
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

            var submit_form_text = $('form [type=submit]').text();
            $('form [type=submit]').text($('form [type=submit]').data('disable-with'));
            this.$('form button').trigger('ajax:beforeSend.rails');
            var url = Routes.bulk_import_pro_structure_newsletter_mailing_lists_path(structure, newsletter)

            $.ajax(url, {
                data: data,
                type: 'POST',
                success: function success (data) {
                    var mailingList = new Newsletter.Models.MailingList(data.mailing_list);
                    COURSAVENUE.helperMethods.flash(data.message, 'notice');
                    this.collection.updateAllProfileMailingList(data.total);
                    this.collection.add(mailingList, { at: 1 });
                    this.trigger('selected', { model: this.model });
                    this.hideEverything();
                }.bind(this),
                error: function error (data) {
                    var message = data.message || "Une erreur est seurvenue lors de l'import des emails, veuillez rééssayer.";
                    COURSAVENUE.helperMethods.flash(message, 'error');
                },
                complete: function complete () {
                    $('form [type=submit]').text(submit_form_text);
                }.bind(this)
            });
        },

        hideEverything: function hideEverything () {
            this.ui.$show_more_options_button.slideDown();
            this.ui.$import_options.slideUp();
        }
    });
});
