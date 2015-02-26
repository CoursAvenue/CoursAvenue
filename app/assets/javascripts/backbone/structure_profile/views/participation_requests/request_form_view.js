StructureProfile.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.RequestFormView = Marionette.LayoutView.extend({
        template: Module.templateDirname() + 'request_form_view',
        message_failed_to_send_template: Module.templateDirname() + 'message_failed_to_send',

        regions: {
            request_form_content: '[data-type=participation-request-form-content]'
        },

        className: 'panel center-block push--bottom',

        ui: {
            '$message_sent'                           : '[data-type=message-sent]',
            '$participation_request_message_body'     : '[name="message[body]"]',
            '$participation_request_user_phone_number': '[name="user[phone_number]"]',
            '$user_participation_requests_path'       : '[data-type=user-participation-requests-path]',
            '$first_step_form_wrapper'                : '[data-element=first-step-form-wrapper]',
            '$second_step_form_wrapper'               : '[data-element=second-step-form-wrapper]'
        },

        events: {
            'click [data-behavior=show-second-step-form]': 'showSecondStepForm',
            'click [data-behavior=show-first-step-form]' : 'showFirstStepForm',
            'click'                                      : 'trackEvent',
            'submit form'                                : 'submitForm',
            'click [data-behavior=show-phone-numbers]'   : 'showPhoneNumbers'
        },

        initialize: function initialize (options) {
            Backbone.Validation.bind(this);
            _.bindAll(this, 'showPopupMessageDidntSend');
        },

        showPhoneNumbers: function showPhoneNumbers () {
            this.$('.phone_number').slideToggle();
        },

        /*
         * Set attributes on message model for validations
         */
        populateRequest: function populateRequest (event) {
            // Retrieve all attributes regarding the name of their input
            var new_attributes = {}
            this.$('[name^="participation_request["]').each(function (index, input) {
                $input         = $(input);
                attribute_name = $input.attr('name').replace('participation_request[', '').replace(']', '');
                new_attributes[attribute_name] = $input.val();
            });
            _.extend(new_attributes, {
                structure_id: this.model.get('structure').get('id'),
                message: {
                    body: this.ui.$participation_request_message_body.val()
                },
                user: {
                    phone_number: this.ui.$participation_request_user_phone_number.val()
                }
            });
            this.model.set(new_attributes);
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
            var request_form_view = new Module.RequestFormView( { structure: this.model.get('structure'), model: this.model } ).render();
            $.magnificPopup.open({
                  items: {
                      src: $(request_form_view.$el),
                      type: 'inline'
                  }
            });
            request_form_view.$el.css('max-width', '400px');
        },

        trackEvent: function trackEvent () {
            if (CoursAvenue.isProduction()) {
              mixpanel.track('Structures/show: interacts with the form');
            }
        },
        /*
         * Called when the form is submitted.
         * If user is connected, will post the message, else, will ask to login first.
         */
        submitForm: function submitForm () {
            if (CoursAvenue.isProduction()) { mixpanel.track('Structures/show: submit form'); }
            this.populateRequest();
            $.cookie('participation_request_body', this.ui.$participation_request_message_body.val());
            $.cookie('user_phone_number'         , this.ui.$participation_request_user_phone_number.val());
            if (this.model.isValid(true)) {
                if (CoursAvenue.currentUser().isLogged()) {
                    this.$('form').trigger('ajax:beforeSend.rails');
                    this.saveMessage();
                } else {
                    CoursAvenue.signUp({
                        title: 'Enregistrez-vous pour envoyer votre message',
                        after_sign_up_popup_title: "Demande d'inscription envoyée",
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
                this.showErrors();
            }
            return false;
        },

        showErrors: function showErrors () {
            this.$('[data-errors]').hide();
            _.each(this.errors, function(value, key) {
                // We replace `.` by `_` because we can't have `.` in data attributes
                key = key.replace('.', '_');
                this.$('[data-error=' + key + ']').text(value).show();
            }, this);
        },

        /*
         * Save message model. Will make a POST request to save the message.
         */
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
                    if (CoursAvenue.isProduction()) { mixpanel.track("Dismissed request form view"); }
                    this.ui.$message_sent.slideDown();
                    this.ui.$user_participation_requests_path.attr('href', Routes.user_participation_requests_path({ id: CoursAvenue.currentUser().get('slug') }));
                }.bind(this),
                error: this.showPopupMessageDidntSend
            });
        },

        showPopupMessageDidntSend: function showPopupMessageDidntSend (model, response) {
              this.$('form').trigger('ajax:complete.rails');
              var popup_to_show = JSON.parse(response.responseText).popup_to_show;
              $.magnificPopup.open({
                    items: {
                        src: $(popup_to_show),
                        type: 'inline'
                    }
              });
        },

        serializeData: function serializeData () {
            var date, data, structure_json;
            date = new Date();
            data = this.model.toJSON();
            data.participation_request.url = this.model.url();
            if (this.errors) { _.extend(data, { errors: this.errors }); }
            structure_json       = this.model.get('structure').toJSON();
            if (CoursAvenue.currentUser().get('last_messages_sent')) {
                _.extend(data, {
                    last_message_sent_at: CoursAvenue.currentUser().get('last_messages_sent')[structure_json.id],
                    user_participation_requests_path: Routes.user_participation_requests_path({ id: CoursAvenue.currentUser().get('slug') })
                });
            }
            $.cookie('user_phone_number')
            _.extend(data, {
                structure: structure_json,
                today: moment().format(GLOBAL.MOMENT_DATE_FORMAT),
                user: {
                    phone_number: CoursAvenue.currentUser().get('phone_number') || $.cookie('user_phone_number')
                }
            });
            return data;
        },

        // Reset course collection passed to content_form_view in order to rerender the course select
        resetCourseCollection: function resetCourseCollection () {
            var courses_array = _.union(this.model.get('structure').get('lessons').models, this.model.get('structure').get('privates').models)
            this.pr_content_view_courses_collection.reset(courses_array);
        },

        showFirstStepForm: function showFirstStepForm () {
            this.ui.$first_step_form_wrapper.slideDown();
            this.ui.$second_step_form_wrapper.slideUp();
        },

        showSecondStepForm: function showSecondStepForm () {
            this.ui.$first_step_form_wrapper.slideUp();
            this.ui.$second_step_form_wrapper.slideDown();
        },

        onRender: function onRender () {
            var courses_array = _.union(this.model.get('structure').get('lessons').models, this.model.get('structure').get('privates').models)
            // We create a new collection from private AND lesson courses
            this.pr_content_view_courses_collection = new Backbone.Collection(courses_array);
            var options =  {
              courses_collection  : this.pr_content_view_courses_collection,
              trainings_collection: this.model.get('structure').get('trainings'),
              model               : this.model
            };
            // Don't re render content_form_view because it's being
            if (!this.pr_content_view & this.$(this.regions.request_form_content).length > 0) {
                this.pr_content_view = new CoursAvenue.Views.ParticipationRequests.ParticipationRequestFormContentView(options);
                this.getRegion('request_form_content').show(this.pr_content_view);
                this.ui.$participation_request_message_body.preventFromContact();
            }
        }
    });

}, undefined);

