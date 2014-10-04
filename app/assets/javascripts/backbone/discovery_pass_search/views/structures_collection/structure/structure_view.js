
DiscoveryPassSearch.module('Views.StructuresCollection.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = FilteredSearch.Views.StructuresCollection.Structure.StructureView.extend({

        events: {
            'click'                                  : 'goToStructurePage',
            'click [data-behavior=accordion-control]': 'accordionControl',
            'mouseenter'                             : 'delegateMouseEnter',
            'mouseleave'                             : 'delegateMouseLeave'
        },

        delegateMouseEnter: function () {
            this.highlightStructure();
        },

        delegateMouseLeave: function () {
            this.unhighlightStructure();
        }
    });
});

