
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfile = Backbone.Model.extend({
        url: function () {
            return Routes.pro_structure_user_profile_path(this.get('structure_id'), this.get('id'), { format: 'json' })
        },

    });
});
