StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.ExpandedStructureLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'expanded_structure_layout',
        className: 'expanded-structure-layout',
        master_region_name: 'expanded_structure',

        regions: {
            master: "#map-places",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

    });
});

