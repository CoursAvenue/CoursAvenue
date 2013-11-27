UserManagement.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfilesLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'user_profiles_layout',
        className: 'relative',

        regions: {
            results: "#search-results",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

    });
});

