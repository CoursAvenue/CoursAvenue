
/* just a basic marionette view */
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignInView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_in_view',

        initialize: function initialize () {
            this.render();
            $.fancybox(this.$el, { width: 270, maxWidth: 270, minWidth: 270 });
        },

        events: {
            'click [data-behavior=sign-up]': 'signUp',
            'submit form'                  : 'signIn'
        },

        signUp: function signUp () {
            new Module.SignUpView();
            return false;
        },

        signIn: function signIn () {
            $.ajax({
                url: Routes.user_session_path(),
                type: 'POST',
                data: {
                    user: {
                        email: this.$('[name=email]').val(),
                        password: this.$('[name=password]').val()
                    }
                },
                error: function error (response) {
                    debugger
                },
                success: function success (response) {
                    debugger
                }
            });
            return false;
        }
    });
});
