
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

        /*
         * Add or remove from favorite regarding if user has already fave it
         */
        addOrRemoveStructureFromFavorite: function addOrRemoveStructureFromFavorite (structure_id, options) {
            var url;
            options = options || {};
            if ( this.get('favorite_structure_ids').indexOf(structure_id) != -1 ) {
                url = Routes.remove_from_favorite_structure_path(structure_id);
                this.set('favorite_structure_ids', _.without(this.get('favorite_structure_ids'), structure_id));
            } else {
                url = Routes.add_to_favorite_structure_path(structure_id);
                // Add current user to favorite
                this.get('favorite_structure_ids').push(structure_id);
            }
            $.ajax({
                beforeSend: function beforeSend (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                url: url,
                type: 'POST',
                dataType: 'json',
                error: (options.error || $.noop),
                success: (options.success || $.noop)
            });
        },

    });
});
