
StructureProfile.module('Views.Messages', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.MessageFormView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'message_form_view',
        message_failed_to_send_template: Module.templateDirname() + 'message_failed_to_send',
        className: 'panel center-block',

        initialize: function initialize (options) {
            this.model = options.model; // Message
            Backbone.Validation.bind(this);
            _.bindAll(this, 'showPopupMessageDidntSend');
            if (this.model.get('structure')) {
                CoursAvenue.statistic.logStat(this.model.get('structure').get('id'), 'action', {});
            }
        },

        ui: {
            '$user_conversations_path': '[data-type=user-conversations-path]'
        },

        onRender: function onRender () {
            setTimeout(COURSAVENUE.chosen_initializer, 5)
        },

        events: {
            'submit form'                             : 'submitForm',
            'click [data-behavior=show-phone-numbers]': 'showPhoneNumbers'
        },

        showPhoneNumbers: function showPhoneNumbers () {
            this.$('.phone_number').slideToggle();
        },

        /*
         * Set attributes on message model for validations
         */
        populateMessage: function populateMessage (event) {
            this.model.set({
                structure_id  : this.model.get('structure').get('id'),
                extra_info_ids: _.map(this.$('[name="extra_info_ids[]"]:checked'), function(input) { return input.value }),
                course_ids    : this.$('[name="course_ids[]"]').val(),
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
            if (this.model.isValid(true)) {
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
                this.errors = this.model.validate();
                if (this.errors['user.phone_number']) {
                    this.errors.user = { phone_number: this.errors['user.phone_number'] }
                }
                this.render();
            }
            return false;
        },

        /*
         * Save message model. Will make a POST request to save the message.
         */
        saveMessage: function saveMessage () {
            // Save sent message to cookie to reuse it on another page.
            $.cookie('last_sent_message', JSON.stringify(this.model.toJSON()));
            this.$('.input_field_error').remove();
            this.model.save(null, {
                success: function success (model, response) {
                    if (CoursAvenue.isProduction()) {
                        ga('send', 'event', 'Action', 'message');
                    }
                    this.$('form').trigger('ajax:complete.rails');
                    this.ui.$user_conversations_path.attr('href', Routes.user_conversations_path({ id: CoursAvenue.currentUser().get('slug') }));
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

        showPopupMessageDidntSend: function showPopupMessageDidntSend (model, response) {
              this.$('form').trigger('ajax:beforeSend.rails');
              var response = JSON.parse(response.responseText);
              $.magnificPopup.open({
                    items: {
                        src: $(response.popup_to_show),
                        type: 'inline'
                    }
              });
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            if (this.errors) { _.extend(data, { errors: this.errors }); }
            _.extend(data, {
                structure: this.model.get('structure').toJSON()
            });
            if (CoursAvenue.currentUser().get('last_messages_sent')) {
                _.extend(data, {
                    last_message_sent_at: CoursAvenue.currentUser().get('last_messages_sent')[this.model.get('structure').get('id')],
                    user_conversations_path: Routes.user_conversations_path({ id: CoursAvenue.currentUser().get('slug') })
                })
            }
            return data;
        }
    });

}, undefined);
