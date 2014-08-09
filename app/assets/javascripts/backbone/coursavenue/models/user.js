
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.User = Backbone.RelationalModel.extend({
        validation: {
            first_name: {
                required: true,
                msg: 'Doit être rempli'
            },
            last_name : {
                required: true,
                msg: 'Doit être rempli'
            },
            email     : {
                required: true,
                pattern: 'email',
                msg: 'Mauvais format'
            },
            zip_code  : {
                required: true,
                pattern: 'digits',
                length: 5,
                msg: 'Mauvais format'
            },
            password  : {
                required: true,
                minLength: 6,
                msg: 'Votre mot de passe est trop court'
            }
        },

        /*
         * Check if user email is from Hotmail
         * Return Boolean
         */
        isFromHotmail: function isFromHotmail () {
            if (!this.get('email')) { return false; }
            return !_.isEmpty(this.get('email').match(/hotmail|live/));
        },

        /*
         * Check if user email is from Gmail
         * Return Boolean
         */
        isFromGmail: function isFromGmail () {
            if (!this.get('email')) { return false; }
            return !_.isEmpty(this.get('email').match('gmail'));
        },

        /*
         * Check wether the user is signed in or not.
         * Return Boolean
         */
        isLogged: function isLogged () {
            return !_.isUndefined(this.get('id'));
        },

    });
});
