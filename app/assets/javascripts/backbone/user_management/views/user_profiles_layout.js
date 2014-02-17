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
            }
        },

        onRender: function () {
            this.$("[data-behavior=sticky-controls]").sticky();
        },

        showFilters: function() {
            var visible  = this.$("[data-type=filters-wrapper]").is(':visible');
            var text     = (visible ?  "Afficher les filtres avancés" : "Cacher les filtres avancés");
            this.$('[data-behavior="filters"]').text(text);
            this.$("[data-type=filters-wrapper]").slideToggle();
        }

    });
});

