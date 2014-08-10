CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignInView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_in_view',
        className: 'panel center-block',

        initialize: function initialize (options) {
            this.model = CoursAvenue.currentUser();
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
            this.$('form').trigger('ajax:beforeSend.rails');
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
                    this.$('form').trigger('ajax:complete.rails');
                }.bind(this),
                error: function error (response) {
                    this.$('[data-type=errors]').show();
                }.bind(this),
                success: function success (response) {
                    CoursAvenue.setCurrentUser(response);
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
