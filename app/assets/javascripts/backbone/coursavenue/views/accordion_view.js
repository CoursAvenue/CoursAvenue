CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.AccordionView = Backbone.Marionette.CompositeView.extend({

        initialize: function () {
            this.currently_selected_cid = [];
        },

        onChildviewAccordionClose: function (view, model_cid) {
            var index = this.currently_selected_cid.indexOf(model_cid);
            if (index > -1) {
                this.currently_selected_cid.splice(index, 1);
            }
        },

        /* function that is called in order to clear the currently active accordion */
        onChildviewAccordionOpen: function(view, model_cid) {
            /*
            if (this.currently_selected_cid) {
                var child_view = this.children.findByModelCid(this.currently_selected_cid);

                if (child_view) {
                    child_view.accordionClose();
                }
            }*/

            this.currently_selected_cid.push(model_cid);
            view.trigger('show');
        },

        /* we don't use this, but we could */
        accordionCloseAll: function () {
            var self = this;

            _.each(_.clone(this.currently_selected_cid), function(cid) {
                var childView = self.children.findByModelCid(cid);
                childView.accordionToggle(childView.active_region);
            });
        }
    });
});
