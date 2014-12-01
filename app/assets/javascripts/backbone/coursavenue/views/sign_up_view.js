CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignUpView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_up_view',
        after_sign_up_popup_template: Module.templateDirname() + 'after_sign_up_popup',
        className: 'panel center-block',

        options: {
            width: 280
        },

        initialize: function initialize (options) {
            this.model = CoursAvenue.currentUser();
            _.extend(this.options, options || {});
            this.options.success = this.options.success || $.magnificPopup.close;
            this.options.success = _.wrap(this.options.success, function(func) {
                CoursAvenue.trigger('user:signed:in');
                CoursAvenue.trigger('user:signed:up');
                func();
            });
            this.$el.css('width', this.options.width + 'px');
            $.magnificPopup.open({
                  items: {
                      src: this.$el,
                      type: 'inline'
                  }
            });
            Backbone.Validation.bind(this);
            this.render();
        },

        events: {
            'click [data-behavior=sign-in]'       : 'signIn',
            'click @ui.$show_email_section_link'  : 'showEmailSection',
            'submit form'                         : 'signUp'
        },

        ui: {
            '$show_email_section_link': '[data-behavior=sign-up-with-email]',
            '$email_section'          : '[data-type=email-section]',
            '$facebook_login_button'  : '[data-behavior=facebook-login]',
            '$data_loader'            : '[data-loader]'
        },

        signIn: function signIn () {
            new Module.SignInView(this.options);
        },

        showEmailSection: function showEmailSection () {
            this.ui.$show_email_section_link.slideUp();
            this.ui.$email_section.slideDown();
        },

        updateModel: function updateModel () {
            _.each(this.$('[name]'), function(input) {
                this.model.set(input.name, input.value);
            }.bind(this));
        },

        signUp: function signIn () {
            this.updateModel();
            if (this.model.isValid(true)) {
                this.$('form').trigger('ajax:beforeSend.rails');
                $.ajax({
                    beforeSend: function beforeSend (xhr) {
                        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                    },
                    url: Routes.user_registration_path(),
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        user: this.model.toJSON()
                    },
                    complete: function complete (response) {
                        this.$('form').trigger('ajax:complete.rails');
                    }.bind(this),
                    error: function error (response) {
                        var errors = $.parseJSON(response.responseText).errors;
                        _.each(errors, function(value, key) {
                            errors[key] = _.uniq(value);
                        });
                        this.errors = errors;
                        this.render();
                    }.bind(this),
                    success: function success (response) {
                        CoursAvenue.setCurrentUser(response);
                        if (CoursAvenue.isProduction()) {
                            mixpanel.track("User registered", { info: 'Standard' });
                            ga('send', 'event', 'Action', 'User registered');
                        }
                        this.showRegistrationConfirmedPopup()
                        // Pixel to track registration convertion with Facebook
                        if (window._fbq) { window._fbq.push(['track', '6016889463627', {}]); }
                    }.bind(this)
                });
            } else {
                this.errors = this.model.validate();
                this.render();
            }
            return false;
        },

        showRegistrationConfirmedPopup: function showRegistrationConfirmedPopup () {
            var data = {};
            if (this.model.isFromHotmail()) { data.from_hotmail = true; }
            if (this.model.isFromGmail())   { data.from_gmail   = true; }
            $.magnificPopup.close();
            // Waits for the popup to close to open new one.
            _.delay(function() {
                $.magnificPopup.open({
                      items: {
                          src: JST[this.after_sign_up_popup_template](data),
                          type: 'inline'
                      },
                      callbacks: {
                          afterClose: this.options.success
                      }
                });
            }.bind(this), 500);
        },

        serializeData: function serializeData () {
            var data = {};
            _.extend(data, this.options);
            _.extend(data, { pages_mentions_partners_path: Routes.pages_mentions_partners_path() });
            _.extend(data, this.model.toJSON());
            if (this.errors) { _.extend(data, { errors: this.errors }); }
            _.extend(data, this.options);
            return data;
        }

    });
});
