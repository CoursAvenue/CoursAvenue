
/* just a basic marionette view */
HomeIndexStructures.module('Views.StructuresCollection.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'structure_view',
        tagName: 'li',
        className: 'structure',
        attributes: {
            'data-behaviour': 'top-structure'
        },

        onRender: function() {
            $("img").lazyload({
                effect : "fadeIn"
            });
        }
    });
});
