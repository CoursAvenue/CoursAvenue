UserManagement.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfilesLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'user_profiles_layout',
        className: 'relative',
        master_region_name: 'user_profiles',

        regions: {
            master: "#search-results",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
                this.$("[data-behavior=sticky-controls]").sticky({
                    offsetTop: 45,
                    oldWidth: true
                });
            }
        }
    });
});

