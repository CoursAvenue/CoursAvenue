CoursAvenue = new Backbone.Marionette.Application({
    slug: 'coursavenue',

    setCurrentAdmin: function setCurrentAdmin (admin_attributes) {
        this.admin.set(admin_attributes);
    },

    currentAdmin: function currentAdmin () {
        return this.admin;
    },

    setCurrentUser: function setCurrentUser (user_attributes) {
        this.user.set(user_attributes);
    },

    currentUser: function currentUser () {
        return this.user;
    },

    /*
     * Try to login in user by showing the sign in/up popup
     * options:
     *     success: function - callback executed if user correctly signs in / up
     *     dismiss: function - callback executed if user dismiss the modal
     *
     */
    signIn: function signIn (options) {
        new CoursAvenue.Views.SignInView(options);
    },

    /*
     * Try to login in user by showing the sign in/up popup
     * options:
     *     success: function - callback executed if user correctly signs in / up
     *     dismiss: function - callback executed if user dismiss the modal
     *
     */
    signUp: function signUp (options) {
        new CoursAvenue.Views.SignUpView(options);
    },

    loginWithFacebook: function loginWithFacebook (options) {
        FB.login(function(response) {
            if (response.status === 'connected') {
                $.ajax({
                    url: Routes.user_omniauth_callback_path({ action: 'facebook' }),
                    type: 'GET',
                    dataType: 'json',
                    error: function error (response) {
                        if (options.error) { options.error(); }
                    },
                    success: function success (response) {
                        this.setCurrentUser(response);
                        if (options.success) {
                            options.success();
                        } else {
                            $.magnificPopup.close();
                        }
                    }.bind(this)
                });
                // Logged into your app and Facebook.
            } else if (response.status === 'not_authorized') {
                options.error();
                GLOBAL.flash('Nous ne pouvons vous authentifier')
                // The person is logged into Facebook, but not your app.
            } else {
              // The person is not logged into Facebook, so we're not sure if
              // they are logged into this app or not.
            }
        }.bind(this), { scope: 'public_profile,email,user_location,user_birthday,user_activities'});
    }
});

CoursAvenue.addRegions({
    userNav: '#user-nav'
});

CoursAvenue.addInitializer(function(options){
    this.user = new CoursAvenue.Models.User();
    this.admin = new CoursAvenue.Models.Admin();
});

$(function() {
    CoursAvenue.start({});
    CoursAvenue.userNav.show(new CoursAvenue.Views.UserNavView({ model: CoursAvenue.currentUser() }));
});
