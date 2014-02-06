StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureHeadersLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'structure_headers_layout',
        className: 'structure-headers-layout',
        master_region_name: 'structure_headers',

        regions: {
            master: "#structure-headers",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

    });
});

