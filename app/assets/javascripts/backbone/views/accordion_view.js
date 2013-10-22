FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.AccordionView = Backbone.Marionette.CompositeView.extend({

        /* function that is called in order to clear the currently active accordion */
        onItemViewAccordionOpen: function(modelcid) {
            if (this.currentSelectedCid) {
                var childView = this.children[this.currentSelectedCid];

                if (childView) {
                    childView.itemDeselect();
                }
            }
            this.currentSelectedCid = modelcid;
        }
    });
});
