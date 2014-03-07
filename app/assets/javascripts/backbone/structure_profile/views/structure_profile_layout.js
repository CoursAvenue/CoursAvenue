StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureProfileLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'structure_profile_layout',
        master_region_name: 'structure'

    });
});

