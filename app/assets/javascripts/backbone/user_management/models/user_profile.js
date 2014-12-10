
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfile = Backbone.Model.extend({
        initialize: function initialize() {
            _.bindAll(this, 'blurContacts');
            this.on('change', this.blurContacts);
        },

        blurContacts: function blurContacts () {
            if (!CoursAvenue.currentAdmin().isPremium()) {
                this.set('email', this.get('email').replace(/.*@/, 'XXXXXXXX@'));
            }
        },

        url: function url () {
            if (this.get('id')) {
                return Routes.pro_structure_user_profile_path(this.get('structure_id'), this.get('id'), { format: 'json' })
            } else {
                return Routes.pro_structure_user_profiles_path(this.get('structure_id'), { format: 'json' })
            }
        },

    });
});
