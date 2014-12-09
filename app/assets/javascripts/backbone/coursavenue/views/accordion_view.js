CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.AccordionView = Backbone.Marionette.CompositeView.extend({

        initialize: function initialize () {
            this.currently_selected_cid = [];
        },

        onItemviewAccordionClose: function onItemviewAccordionClose (view, model_cid) {
            var index = this.currently_selected_cid.indexOf(model_cid);
            if (index > -1) {
                this.currently_selected_cid.splice(index, 1);
            }
        },

        /* function that is called in order to clear the currently active accordion */
        onItemviewAccordionOpen: function onItemviewAccordionOpen(view, model_cid) {
            this.currently_selected_cid.push(model_cid);
            view.trigger('show');
        },

        /* we don't use this, but we could */
        accordionCloseAll: function accordionCloseAll () {
            var self = this;

            _.each(_.clone(this.currently_selected_cid), function(cid) {
                var itemView = self.children.findByModelCid(cid);
                itemView.accordionToggle(itemView.active_region);
            });
        }
    });
});
