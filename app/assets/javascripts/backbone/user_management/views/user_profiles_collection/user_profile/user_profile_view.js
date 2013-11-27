
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfileView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_profile_view'

    });
});
