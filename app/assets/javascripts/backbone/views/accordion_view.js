FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.AccordionView = Backbone.Marionette.CompositeView.extend({

        onItemviewAccordionClose: function (view, model_cid) {
            this.currently_selected_cid = undefined;
        },

        /* function that is called in order to clear the currently active accordion */
        onItemviewAccordionOpen: function(view, model_cid) {
            if (this.currently_selected_cid) {
                var child_view = this.children.findByModelCid(this.currently_selected_cid);

                if (child_view) {
                    child_view.accordionClose();
                }
            }
            this.currently_selected_cid = model_cid;
        }
    });
});
