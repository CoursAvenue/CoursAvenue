/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.StructureView = Views.AccordionItemView.extend({
        template: 'backbone/templates/structure_view',

        tagName: 'li',
        className: 'one-whole course-element',
        attributes: {
            'data-type': 'structure-element'
        },

        initialize: function(options) {
            console.log("StructureView->initialize");

            this.$el.data('url', options.model.get('data_url'));
        },

        events: {
            'click': 'accordionOpen',
            'mouseenter': 'highlightStructure',
            'mouseleave': 'unhighlightStructure'
        },

        /* return toJSON for the places relation */
        placesToJSON: function () {
            return this.model.getRelation('places').related.models.map(function (model) {
                return _.extend(model.toJSON(), { cid: model.cid });
            });
        },

        /* a structure was selected, so return the places JSON
        * TODO would it be nicer is this just returned the whole model's
        * json, including the places relation? */
        highlightStructure: function (e) {
            this.trigger('highlighted', this.placesToJSON());
        },

        unhighlightStructure: function (e) {
            this.trigger('unhighlighted', this.placesToJSON());
        },

        resolveClick: function (event) {
            if (event.target.nodeName !== 'A') {
                if (event.metaKey || event.ctrlKey) {
                    window.open(this.model.get('data_url'));
                } else {
                    window.location = this.model.get('data_url');
                }
                return false;
            }
        }

    });
});
