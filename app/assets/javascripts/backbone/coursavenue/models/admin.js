
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Admin = Backbone.Model.extend({

        /*
         * Check wether the user is signed in or not.
         * Return Boolean
         */
        isLogged: function isLogged () {
            return !_.isUndefined(this.get('id'));
        }

    });
});
