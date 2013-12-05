HomeIndexStructures.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.TopStructuresLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'top_structures_layout',
        className: 'top-structures-layout grid',
        master_region_name: 'top_structure',

        regions: {
            master: "#top-structures",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

    });
});

