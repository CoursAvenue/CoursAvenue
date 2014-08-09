CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignUpView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_up_view',
        after_sign_up_popup_template: Module.templateDirname() + 'after_sign_up_popup',
        className: 'panel center-block',

        initialize: function initialize (options) {
            this.model = new CoursAvenue.Models.User (options.user || {});
            this.options = options;
            this.$el.css('width', '280px');
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
            'click [data-behavior=facebook-login]': 'loginWithFacebook',
            'submit form'                         : 'signUp'
        },

        ui: {
            '$show_email_section_link': '[data-behavior=sign-up-with-email]',
            '$email_section'          : '[data-type=email-section]'
        },

        signIn: function signIn () {
            new Module.SignInView(this.options);
        },

        loginWithFacebook: function loginWithFacebook () {
            CoursAvenue.loginWithFacebook({
                success: this.options.success,
                dismiss: this.options.dismiss
            });
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
                var $submit_button  = this.$('[data-disable-with]');
                var old_button_text = $submit_button.text();
                $submit_button.attr('disabled', true);
                $submit_button.text($submit_button.data('disable-with'))
                $.ajax({
                    url: Routes.user_registration_path(),
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        user: this.model.toJSON()
                    },
                    complete: function complete (response) {
                        $submit_button.text(old_button_text);
                        $submit_button.removeAttr('disabled');
                    },
                    error: function error (response) {
                        var errors = $.parseJSON(response.responseText).errors;
                        _.each(errors, function(value, key) {
                            errors[key] = _.uniq(value);
                        });
                        this.errors = errors;
                        this.render();
                    }.bind(this),
                    success: function success (response) {
                        CoursAvenue.setCurrentUser(new CoursAvenue.Models.User(response));
                        this.showRegistrationConfirmedPopup()
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
            _.extend(data, { pages_mentions_partners_path: Routes.pages_mentions_partners_path() });
            _.extend(data, this.model.toJSON());
            if (this.errors) { _.extend(data, { errors: this.errors }); }
            _.extend(data, this.options);
            return data;
        }

    });
});
