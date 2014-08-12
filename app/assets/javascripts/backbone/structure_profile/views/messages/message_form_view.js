
StructureProfile.module('Views.Messages', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.MessageFormView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'message_form_view',
        message_failed_to_send_template: Module.templateDirname() + 'message_failed_to_send',
        className: 'panel center-block push--bottom',

        initialize: function initialize (options) {
            this.structure = options.structure;
            this.model = new StructureProfile.Models.Message();
            this.$el.css('max-width', '400px');
            _.bindAll(this, 'showPopupMessageDidntSend');
        },

        onRender: function onRender () {
            // Not having panel class for sleeping structures
            if (this.structure.get('is_sleeping')){
                this.$el.removeClass('panel');
                if (this.structure.get('phone_numbers').length == 0) {
                    this.$el.removeClass('push--bottom');
                }
            }
        },
        events: {
            'submit form'                             : 'submitForm',
            'click [data-behavior=show-phone-numbers]': 'showPhoneNumbers'
        },

        showPhoneNumbers: function showPhoneNumbers () {
            this.$('.phone_number').slideToggle();
        },

        populateMessage: function populateMessage (event) {
            this.model.set({
                structure_id  : this.structure.get('id'),
                extra_info_ids: _.map(this.$('[name="extra_info_ids[]"]:checked'), function(input) { return input.value }),
                course_ids    : _.map(this.$('[name="course_ids[]"]:checked'), function(input) { return input.value }),
                body          : this.$('[name=body]').val(),
                user: {
                    first_name  : this.$('[name="user[first_name]"]').val(),
                    email       : this.$('[name="user[email]"]').val(),
                    phone_number: this.$('[name="user[phone_number]"]').val()
                }
            });
        },

        /*
         * Called when the form is submitted.
         * If user is connected, will post the message, else, will ask to login first.
         */
        submitForm: function submitForm () {
            this.populateMessage();
            if (this.model.valid()) {
                if (CoursAvenue.currentUser().isLogged()) {
                    this.$('form').trigger('ajax:beforeSend.rails');
                    this.saveMessage();
                } else {
                    CoursAvenue.signUp({
                        title: 'Enregistrez-vous pour envoyer votre message',
                        // Passing the user in order to keep the email and more if we need.
                        user: this.model.get('user'),
                        success: function success (response) {
                            this.saveMessage();
                        }.bind(this),
                        dismiss: this.showPopupMessageDidntSend
                    });
                }
            } else {
                this.showErrors();
            }
            return false;
        },

        /*
         * TODO, user backbone validation
         */
        showErrors: function showErrors () {
            this.$('.input_field_error').remove();
            _.each(this.model.get('errors'), function(error, name) {
                var error = $('<div>').addClass('input_field_error red text--right one-whole').text(error)
                this.$('[name="' + name + '"]').closest('.input').append(error);
            });
        },

        /*
         * Save message model. Will make a POST request to save the message.
         */
        saveMessage: function saveMessage () {
            this.model.sync({
                success: function success (response) {
                    this.$('form').trigger('ajax:complete.rails');
                    $.magnificPopup.open({
                          items: {
                              src: $(response.popup_to_show),
                              type: 'inline'
                          }
                    });
                }.bind(this),
                error: this.showPopupMessageDidntSend
            });
        },

        showPopupMessageDidntSend: function showPopupMessageDidntSend () {
              $.magnificPopup.open({
                    items: {
                        src: $(),
                        type: 'inline'
                    }
              });
        },

        onAfterShow: function onAfterShow () {
            GLOBAL.chosen_initializer();
        },

        serializeData: function serializeData () {
            return {
                structure: this.structure.toJSON(),
                prefilled_body: "Bonjour,\n\nJe souhaiterais venir pour une première séance. Pouvez-vous m’envoyer la date du prochain cours et toutes les autres informations nécessaires (tenue exigée, confirmation du lieu, etc.).\n\nMerci et à très bientôt"
            }
        }
    });

}, undefined);
