
/* just a basic marionette view */
StructurePlanning.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = StructureProfile.Views.Structure.StructureView.extend({
        template: Module.templateDirname() + 'structure_view'
    });
});
