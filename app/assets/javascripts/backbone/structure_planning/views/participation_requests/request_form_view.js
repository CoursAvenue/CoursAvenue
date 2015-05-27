StructurePlanning.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.RequestFormView = StructureProfile.Views.ParticipationRequests.RequestFormView.extend({
        template: Module.templateDirname() + 'request_form_view',
        message_failed_to_send_template: StructureProfile.Views.ParticipationRequests.templateDirname() + 'message_failed_to_send',

        initialize: function initialize (options) {
            StructureProfile.Views.ParticipationRequests.RequestFormView.prototype.initialize.apply(this, arguments);
            _.bindAll(this, 'stripeResponseHandler', 'showSubmitError');
        },

        ui: {
            '$message_sent'                           : '[data-type=message-sent]',
            '$participation_request_message_body'     : '[name="message[body]"]',
            '$participation_request_user_phone_number': '[name="user[phone_number]"]',
            '$participation_request_user_email'       : '[name="user[email]"]',
            '$participation_request_user_name'        : '[name="user[name]"]',
            '$participation_request_card_token'       : '[name="card[token]"]',
            '$user_participation_requests_path'       : '[data-type=user-participation-requests-path]',
            '$first_step_form_wrapper'                : '[data-element=first-step-form-wrapper]',
            '$second_step_form_wrapper'               : '[data-element=second-step-form-wrapper]',
            '$third_step_form_wrapper'                : '[data-element=third-step-form-wrapper]',
            '$form_submit'                            : '[data-element=form-submit]',
            '$input_exp'                              : '[name="card[exp]"]',
            '$hidden_input_exp_month'                 : '[name="card[exp_month]"]',
            '$hidden_input_exp_year'                  : '[name="card[exp_year]"]',
            '$input_cvc'                              : '[name="card[cvc]"]',
            '$input_card_number'                      : '[name="card[number]"]'
        },

        onShow: function onShow () {
            this.ui.$input_card_number.payment('formatCardNumber');
            this.ui.$input_exp.payment('formatCardExpiry');
            this.ui.$input_cvc.payment('formatCardCVC');
        },

        /*
         * Override the events hash from the parent View.
         * Indeed, by default, Marionette doens't merge the different child event hash with the
         * parent event hash, so we do it manually.
         */
        events: function events () {
            _events = {
                'click [data-behavior=show-third-step-form]': 'showThirdStepForm',
                'submit form':                                'preSubmitForm'
            };

            return _.extend(StructureProfile.Views.ParticipationRequests.RequestFormView.prototype.events, _events);
        },

        /*
         * Called right before the form is submitted.
         * Check whether we need to get a Stripe token or not.
         */
        preSubmitForm: function preSubmitForm () {
            this.populateRequest();
            if (!this.model.isValid(true)) {
                this.showErrors();
                return false;
            }
            if (this.model.isFree()) {
                return this.submitForm();
            } else {
                var expiry_date = $.payment.cardExpiryVal(this.ui.$input_exp.val());
                this.ui.$hidden_input_exp_month.val(expiry_date.month);
                this.ui.$hidden_input_exp_year.val(expiry_date.year);
                Stripe.card.createToken(this.$('form'), this.stripeResponseHandler);
                return false;
            }
        },

        /*
         * Called when the form is submitted.
         * If user is connected, will post the message, else, will ask to login first.
         */
        submitForm: function submitForm () {
            $.cookie('participation_request_body', this.ui.$participation_request_message_body.val());
            $.cookie('user_phone_number'         , this.ui.$participation_request_user_phone_number.val());

            if (this.model.isValid(true)) {
                this.$('form').trigger('ajax:send');
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
                is_free: this.model.isFree(),
                message: {
                    body: this.ui.$participation_request_message_body.val()
                },
                user: {
                    phone_number: this.ui.$participation_request_user_phone_number.val(),
                    email:        this.ui.$participation_request_user_email.val(),
                    name:         this.ui.$participation_request_user_name.val()
                }
            });
            this.model.set(new_attributes);
        },

        saveMessage: function saveMessage () {
            this.$('.input_field_error').hide();
            this.model.save(null, {
                success: function success (model, response) {
                    // We disable the submit button
                    this.$('form').trigger('ajax:complete');
                    $.magnificPopup.open({
                          items: {
                              src: $(response.popup_to_show),
                              type: 'inline'
                          }
                    });
                    this.ui.$message_sent.slideDown();
                }.bind(this),
                error: this.showSubmitError.bind(this)
            });
        },

        /*
         * Called when a user click on "register" on a planning
         * We create an instance of a message form view
         */
        showRegistrationForm: function showRegistrationForm (planning_data) {
            if (this.model.get('structure').get('lessons').findWhere({ id: planning_data.course_id })) {
                this.model.set('course_collection_type', 'lessons');
            } else if (this.model.get('structure').get('privates').findWhere({ id: planning_data.course_id })) {
                this.model.set('course_collection_type', 'privates');
            } else {
                this.model.set('course_collection_type', 'trainings');
            }
            this.model.set('course_id', planning_data.course_id);
            this.model.set('planning_id', planning_data.id);
            var request_form_view = new Module.RequestFormView( { structure: this.model.get('structure'), model: this.model, in_two_steps: true } ).render();
            var request_form_view_el = $(request_form_view.$el);
            request_form_view_el.find('[data-pr-total]').addClass('soft--right');
            $.magnificPopup.open({
                  items: {
                      src: request_form_view_el,
                      type: 'inline'
                  }
            });
            request_form_view.$el.css('max-width', '400px');
        },

        showSecondStepForm: function showSecondStepForm () {
            this.populateRequest();
            // Rejecting errors related to users
            errors = _.reject(this.errors, function(value, key) { return (key.indexOf('user') != -1) })
            if (errors.length == 0) {
                this.ui.$first_step_form_wrapper.slideUp();

                if (!this.model.isFree() && this.selectedCourseAcceptsPayment()) {
                    this.addThirdStepForm();
                    this.ui.$third_step_form_wrapper.slideUp();
                }

                this.ui.$second_step_form_wrapper.slideDown();

                this.$('[data-error]').hide(); // Hide errors if there was any
            } else {
                this.showErrors();
            }
        },

        /*
         * Switch the submition button for the "go to third step" button.
         */
        addThirdStepForm: function addThirdStepForm () {
            this.$('[data-behavior=show-third-step-form]').removeClass('hidden');
            this.$('[data-behavior=skip-third-step-form]').hide();
        },

        showThirdStepForm: function showThirdStepForm () {
            this.populateRequest();
            if (this.model.isValid(true)) {
                this.ui.$second_step_form_wrapper.slideUp();
                this.ui.$third_step_form_wrapper.slideDown();
                this.$('[data-error]').hide(); // Hide errors if there were any
            } else {
                this.showErrors();
            }
        },

        stripeResponseHandler: function stripeResponseHandler (status, response) {
            if (status == 200) {
                this.model.set('stripe_token', response.id);
                this.ui.$participation_request_card_token.val(response.id);
                this.submitForm();
            } else {
                var errorMessage = window.coursavenue.bootstrap.stripe_errors[response.error.code];
                this.$('[data-error=stripe-error]').text(errorMessage).show();
            }
        },

        /*
         * Toggle the payment form depending on whether a course is selected and if the course has
         * payment
         */
        togglePaymentForm: function togglePaymentForm (data) {
            if (data.total_price > 0) {
                this.ui.$third_step_form_wrapper.slideDown();
                this.ui.$form_submit.slideUp();
            } else  {
                this.ui.$third_step_form_wrapper.slideUp();
                this.ui.$form_submit.slideDown();
            }
        },

        getCourse: function getCourse() {
            return this.pr_content_view_courses_collection.findWhere({ id: parseInt(this.model.get('course_id'), 10) });
        },

        selectedCourseAcceptsPayment: function selectedCourseAcceptsPayment() {
            return this.getCourse().get('accepts_payment') == true;
        },

        showSubmitError: function showSubmitError (model, response) {
            if (response.responseJSON.stripe_error_message) {
                var errorMessage = response.responseJSON.stripe_error_message;

                this.$('form').trigger('ajax:complete');
                this.$('[data-error=stripe-error]').text(errorMessage).show();
            } else {
                return this.showPopupMessageDidntSend(model, response);
            }
        },

    });

}, undefined);

