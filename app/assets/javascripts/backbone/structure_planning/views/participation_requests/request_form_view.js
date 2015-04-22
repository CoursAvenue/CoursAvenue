StructurePlanning.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.RequestFormView = StructureProfile.Views.ParticipationRequests.RequestFormView.extend({
        template: Module.templateDirname() + 'request_form_view',
        message_failed_to_send_template: StructureProfile.Views.ParticipationRequests.templateDirname() + 'message_failed_to_send',

        ui: {
            '$message_sent'                           : '[data-type=message-sent]',
            '$participation_request_message_body'     : '[name="message[body]"]',
            '$participation_request_user_phone_number': '[name="user[phone_number]"]',
            '$participation_request_user_email'       : '[name="user[email]"]',
            '$user_participation_requests_path'       : '[data-type=user-participation-requests-path]',
            '$first_step_form_wrapper'                : '[data-element=first-step-form-wrapper]',
            '$second_step_form_wrapper'               : '[data-element=second-step-form-wrapper]'
        },

        /*
         * Called when the form is submitted.
         * If user is connected, will post the message, else, will ask to login first.
         */
        submitForm: function submitForm () {
            this.populateRequest();
            $.cookie('participation_request_body', this.ui.$participation_request_message_body.val());
            $.cookie('user_phone_number'         , this.ui.$participation_request_user_phone_number.val());
            if (this.model.isValid(true)) {
                this.$('form').trigger('ajax:beforeSend.rails');
                this.saveMessage();
            } else {
                this.showErrors();
            }
            return false;
        },

        /*
         * Set attributes on message model for validations
         */
        populateRequest: function populateRequest (event) {
            // Retrieve all attributes regarding the name of their input
            var new_attributes = {}
            this.$('[name^="participation_request["]').each(function (index, input) {
                if (!$(input).is(':visible')) { return; }
                $input         = $(input);
                attribute_name = $input.attr('name').replace('participation_request[', '').replace(']', '');
                // If it is a nested attributes
                if (attribute_name.indexOf('[') != -1) {
                    // Ex. : "participants_attributes[0][price_id]"
                    var nested_attribute_name             = attribute_name.split('[')[0];
                    var attribute_index                   = attribute_name.split(/(\[[0-9]*\])/)[1].replace('[', '').replace(']', '');
                    var attribute_name                    = attribute_name.split(/(\[[0-9]*\])/)[2].replace('[', '').replace(']', '');
                    new_attributes[nested_attribute_name] = new_attributes[nested_attribute_name] || [];
                    new_attributes[nested_attribute_name][attribute_index] = new_attributes[nested_attribute_name][attribute_index] || {}
                    new_attributes[nested_attribute_name][attribute_index][attribute_name] = $input.val();

                } else {
                    new_attributes[attribute_name] = $input.val();
                }
            });
            _.extend(new_attributes, {
                structure_id: this.model.get('structure').get('id'),
                message: {
                    body: this.ui.$participation_request_message_body.val()
                },
                user: {
                    phone_number: this.ui.$participation_request_user_phone_number.val(),
                    email: this.ui.$participation_request_user_email.val()
                }
            });
            this.model.set(new_attributes);
        },
        saveMessage: function saveMessage () {
            this.$('.input_field_error').remove();
            this.model.save(null, {
                success: function success (model, response) {
                    // We disable the submit button
                    this.$('form').trigger('ajax:complete.rails');
                    $.magnificPopup.open({
                          items: {
                              src: $(response.popup_to_show),
                              type: 'inline'
                          }
                    });
                    this.ui.$message_sent.slideDown();
                }.bind(this),
                error: this.showPopupMessageDidntSend
            });
        }

    });

}, undefined);

