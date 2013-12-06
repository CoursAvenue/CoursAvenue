HomeIndexStructures.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructuresLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'structures_layout',
        className: 'structures-layout grid',
        master_region_name: 'structure',

        regions: {
            master: "#structures",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

    });
});

