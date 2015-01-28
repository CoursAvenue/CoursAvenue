StructureProfile.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.RequestFormView = Marionette.LayoutView.extend({
        template: Module.templateDirname() + 'request_form_view',
        message_failed_to_send_template: Module.templateDirname() + 'message_failed_to_send',

        regions: {
            request_form_content: '[data-type=participation-request-form-content]'
        },

        className: 'panel center-block push--bottom',

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
                date          : this.$('[name=date]').val(),
                start_hour    : this.$('[name=start-hour]').val(),
                start_min     : this.$('[name=start-min]').val(),
                message: {
                    body: this.$('[name="message[body]"]').val()
                },
                user: {
                    phone_number: this.$('[name="user[phone_number]"]').val()
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
            $.cookie('participation_request_body', this.$('[name="message[body]"]').val());
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
            var data = this.model.toJSON();
            data.participation_request.url = this.model.url();
            if (this.errors) { _.extend(data, { errors: this.errors }); }
            var structure_json       = this.model.get('structure').toJSON();
            if (CoursAvenue.currentUser().get('last_messages_sent')) {
                _.extend(data, {
                    last_message_sent_at: CoursAvenue.currentUser().get('last_messages_sent')[structure_json.id],
                    user_participation_requests_path: Routes.user_participation_requests_path({ id: CoursAvenue.currentUser().get('slug') })
                });
            }
            _.extend(data, {
                structure: structure_json,
            });
            return data;
        },

        onRender: function onRender () {
            var options =  {
              courses_collection  : this.model.get('structure').get('courses'),
              trainings_collection: this.model.get('structure').get('trainings'),
              model               : this.model,
              selected_course_id  : null,
              selected_planning_id: null
            };
            var pr_content_view = new CoursAvenue.Views.ParticipationRequests.ParticipationRequestFormContentView(options);
            this.getRegion('request_form_content').show(pr_content_view);
        }
    });

}, undefined);

