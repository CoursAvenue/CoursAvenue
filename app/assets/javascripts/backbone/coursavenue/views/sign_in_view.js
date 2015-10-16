CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.SignInView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'sign_in_view',
        className: 'panel center-block',

        options: {
            width: 320
        },

        initialize: function initialize (options) {
            this.model = CoursAvenue.currentUser();
            _.extend(this.options, options || {});
            this.options.success = this.options.success || $.magnificPopup.close;
            this.options.success = _.wrap(this.options.success, function(func) {
                CoursAvenue.trigger('user:signed:in');
                func();
            });
            if (options.el) {
                options.el.append(this.$el);
            } else {
                this.$el.css('width', this.options.width + 'px');
                $.magnificPopup.open({
                      items: {
                          src: this.$el,
                          type: 'inline'
                      }
                });
            }
            this.render();
        },

        events: {
            'click @ui.$facebook_login_button'    : 'loginWithFacebook',
            'click [data-behavior=sign-up]'       : 'signUp',
            'submit form[data-behavior=user-form]': 'signIn',
            'click @ui.$facebook_login_button'    : 'loginWithFacebook'
        },

        ui: {
            '$facebook_login_button'  : '[data-behavior=login-with-facebook]',
            '$data_loader'            : '[data-loader]'
        },

        /*
         * We have to keep this action in this model to ensure to pass this.options attributes
         */
        loginWithFacebook: function loginWithFacebook () {
            CoursAvenue.loginWithFacebook(this.options);
        },

        /*
         * We have to keep this action in this model to ensure to pass this.options attributes
         */
        loginWithFacebook: function loginWithFacebook () {
            CoursAvenue.loginWithFacebook(this.options);
        },

        signUp: function signUp () {
            new Module.SignUpView(this.options);
            return false;
        },

        signIn: function signIn () {
            this.$('form').trigger('ajax:send');
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
                    this.$('form').trigger('ajax:complete');
                }.bind(this),
                error: function error (response) {
                    var json_response = $.parseJSON(response.responseText);
                    if (json_response.is_admin) {
                        this.$('[data-el=form-wrapper]').slideUp();
                        this.$('[data-type=admin-errors]').show();
                    } else {
                        this.$('[data-type=errors]').show();
                    }
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
