
/* this file simply creates a top level Module in which Lib can live */

CoursAvenue = new Backbone.Marionette.Application({
    slug: 'coursavenue',

    /*
     * Try to sign in user by showing the sign in/up popup
     * options:
     *     success: function - callback executed if user correctly signs in / up
     *     failure: function - callback executed if user dismiss the modal
     *
     */
    signInUser: function signIn (options) {
        new CoursAvenue.Views.SignInView();
    }
});

$(document).ready(function() {
    CoursAvenue.start({});
});
