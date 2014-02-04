
OpenDoorsSearch.module('Views.StructuresCollection.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = FilteredSearch.Views.StructuresCollection.Structure.StructureView.extend({

        ui: {
            '$open_doors_button': '[data-type=open-doors-button]'
        },

        events: {
            'click'                                  : 'goToStructurePage',
            'click [data-behavior=accordion-control]': 'accordionControl',
            'mouseenter'                             : 'highlightStructure toggleOpenDoorsButton',
            'mouseleave'                             : 'unhighlightStructure toggleOpenDoorsButton'
        },

        toggleOpenDoorsButton: function () {
            this.ui.$open_doors_button.toggleClass("inline-block");
        }
    });
});

