UserManagement.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfilesLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'user_profiles_layout',
        className: 'relative',
        master_region_name: 'user_profiles',

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

