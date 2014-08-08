
/* just a basic marionette view */
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignUpView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_up_view',
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
            this.ui.$email_section.slideDown();
            this.ui.$show_email_section_link.slideUp();
        },

        signUp: function signIn () {
            this.model.set({
                first_name: this.$('[name=first_name]').val(),
                last_name : this.$('[name=last_name]').val(),
                zip_code  : this.$('[name=zip_code]').val(),
                email     : this.$('[name=email]').val(),
                password  : this.$('[name=password]').val()
            });
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
                    this.$('[data-type=errors]').show();
                }.bind(this),
                success: function success (response) {
                    this.$('[data-type=errors]').slideUp();
                    this.options.success();
                }.bind(this)
            });
            return false;
        },

        serializeData: function serializeData () {
            return _.extend({
                pages_mentions_partners_path: Routes.pages_mentions_partners_path()
            }, this.model.toJSON());
        }

    });
});
