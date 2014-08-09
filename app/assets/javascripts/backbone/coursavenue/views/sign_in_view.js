CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignInView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_in_view',
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
            'click [data-behavior=sign-up]'       : 'signUp',
            'click [data-behavior=facebook-login]': 'loginWithFacebook',
            'submit form'                         : 'signIn'
        },

        loginWithFacebook: function loginWithFacebook () {
            CoursAvenue.loginWithFacebook({
                success: this.options.success,
                dismiss: this.options.dismiss
            });
        },

        signUp: function signUp () {
            new Module.SignUpView(this.options);
            return false;
        },

        signIn: function signIn () {
            var $submit_button  = this.$('[data-disable-with]');
            var old_button_text = $submit_button.text();
            $submit_button.attr('disabled', true);
            $submit_button.text($submit_button.data('disable-with'))
            $.ajax({
                url: Routes.user_session_path(),
                type: 'POST',
                dataType: 'json',
                data: {
                    user: {
                        remember_me       : true,
                        email             : this.$('[name=email]').val(),
                        password          : this.$('[name=password]').val()
                    }
                },
                complete: function complete (response) {
                    $submit_button.text(old_button_text);
                    $submit_button.removeAttr('disabled');
                },
                error: function error (response) {
                    this.$('[data-type=errors]').show();
                }.bind(this),
                success: function success (response) {
                    CoursAvenue.setCurrentUser(new CoursAvenue.Models.User(response));
                    this.$('[data-type=errors]').slideUp();
                    if (this.options.success) { this.options.success(); }
                }.bind(this)
            });
            return false;
        },

        serializeData: function serializeData () {
            return _.extend(this.options, this.model.toJSON());
        }
    });
});
