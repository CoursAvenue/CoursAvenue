StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureProfileLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'structure_profile_layout',

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

