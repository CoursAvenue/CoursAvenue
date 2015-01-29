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
            '$participation_request_date'             : '[name="participation_request[date]"]',
            '$participation_request_start_hour'       : '[name="participation_request[start_hour]"]',
            '$participation_request_start_min'        : '[name="participation_request[start_min]"]',
            '$participation_request_message_body'     : '[name="message[body]"]',
            '$participation_request_user_phone_number': '[name="user[phone_number]"]',
            '$user_participation_requests_path'       : '[data-type=user-participation-requests-path]'
        },

        events: {
            'click'                                   : 'trackEvent',
            'submit form'                             : 'submitForm',
            'click [data-behavior=show-phone-numbers]': 'showPhoneNumbers'
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
            this.model.set({
                structure_id  : this.model.get('structure').get('id'),
                date          : this.ui.$participation_request_date.val(),
                start_hour    : this.ui.$participation_request_start_hour.val(),
                start_min     : this.ui.$participation_request_start_min.val(),
                message: {
                    body: this.ui.$participation_request_message_body.val()
                },
                user: {
                    phone_number: this.ui.$participation_request_user_phone_number.val()
                }
            });
        },

        /*
         * Called when a user click on "register" on a planning
         * We create an instance of a message form view
         */
        showRegistrationForm: function showRegistrationForm (planning_data) {
            if (this.model.get('structure').get('courses').findWhere({ id: planning_data.course_id })) {
                this.model.set('course_collection_type', 'courses');
            } else {
                this.model.set('course_collection_type', 'trainings');
            }
            this.model.set('course_id', planning_data.course_id);
            this.model.set('planning_id', planning_data.id);
            this.selectCourse();
            this.populatePlannings();
            var request_form_view = new Module.RequestFormView( { structure: this.model.get('structure'), model: this.model.toJSON().participation_request } ).render();
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
            _.extend(data, {
                structure: structure_json,
                today: moment().format(GLOBAL.MOMENT_DATE_FORMAT),
                user_participation_requests_path: Routes.user_participation_requests_path({ id: '__USER_ID__' })
            });
            return data;
        },

        onRender: function onRender () {
            // IMPORTANT to rebind ui elements that are nested in the form_content_view
            this.bindUIElements();
            this.ui.$participation_request_message_body.preventFromContact();
            var options =  {
              courses_collection  : this.model.get('structure').get('courses'),
              trainings_collection: this.model.get('structure').get('trainings'),
              model               : this.model
            };
            var pr_content_view = new CoursAvenue.Views.ParticipationRequests.ParticipationRequestFormContentView(options);
            this.getRegion('request_form_content').show(pr_content_view);
        }
    });

}, undefined);

