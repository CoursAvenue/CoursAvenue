CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignInView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_in_view',
        className: 'panel center-block',

        options: {
            show_admin_form      : false,
            width                : 280,
            width_with_admin_form: 560
        },

        initialize: function initialize (options) {
            this.model = CoursAvenue.currentUser();
            _.extend(this.options, options || {});
            this.options.success = this.options.success || $.magnificPopup.close;
            this.options.success = _.wrap(this.options.success, function(func) {
                CoursAvenue.trigger('user:signed:in');
                func();
            });

            this.$el.css('width', this.popupWidth() + 'px');
            $.magnificPopup.open({
                  items: {
                      src: this.$el,
                      type: 'inline'
                  }
            });
            this.render();
        },

        popupWidth: function popupWidth () {
            return (this.options.show_admin_form ? this.options.width_with_admin_form : this.options.width);
        },

        events: {
            'click [data-behavior=sign-up]'       : 'signUp',
            'submit form[data-behavior=user-form]': 'signIn'
        },

        ui: {
            '$facebook_login_button'  : '[data-behavior=facebook-login]',
            '$data_loader'            : '[data-loader]'
        },

        onRender: function onRender () {
            if (this.options.show_admin_form) {
                this.$('[name=authenticity_token]').val($('meta[name="csrf-token"]').attr('content'));
            }
        },
        signUp: function signUp () {
            new Module.SignUpView(this.options);
            return false;
        },

        signIn: function signIn () {
            this.$('form').trigger('ajax:beforeSend.rails');
            $.ajax({
                beforeSend: function beforeSend (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
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
                    this.options.success();
                }.bind(this)
            });
            return false;
        },

        serializeData: function serializeData () {
            var params = { forget_password_path: Routes.new_user_password_path() }
            _.extend(params, this.options);
            _.extend(params, this.model.toJSON());
            return params;
        }
    });
});
