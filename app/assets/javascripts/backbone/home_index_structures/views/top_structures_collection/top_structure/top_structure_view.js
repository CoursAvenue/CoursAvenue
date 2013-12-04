
/* just a basic marionette view */
HomeIndexStructures.module('Views.TopStructuresCollection.TopStructure', function(Module, App, Backbone, Marionette, $, _) {

    Module.TopStructureView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'top_structure_view',
        tagName: 'div',
        className: 'top-structure',
        attributes: {
            'data-behaviour': 'top-structure'
        }
    });
});
