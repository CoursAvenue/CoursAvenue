
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Admin = Backbone.Model.extend({

        /*
         * Check wether the admin is premium or not.
         * Return Boolean
         */
        isPremium: function isLogged () {
            return this.get('premium')
        },

    });
});
