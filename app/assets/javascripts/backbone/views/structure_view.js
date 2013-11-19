/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {


    Views.StructureView = Views.RelationalAccordionItemView.extend({
        template: 'backbone/templates/structure_view',
        tagName: 'li',
        className: 'push-half--bottom',
        attributes: {
            'data-type': 'structure-element hard'
        },

        initialize: function(options) {
            this.$el.data('url', options.model.get('data_url'));

            /* the structure view needs to know how it is being filtered */
            if (options.search_term) {
                this.search_term = options.search_term;
            }
        },

        onRender: function() {
            this.$('[data-behavior=tooltip]').tooltip();
        },

        /* TODO accordioncontrol is defined on the parent, so it feels
        * dirty to have the click handled here. However, it seems that
        * the child's events hash overrides the parent's hash by default */
        events: {
            'click': 'goToStructurePage',
            'click [data-type=accordion-control]': 'accordionControl',
            'mouseenter':                          'highlightStructure',
            'mouseleave':                          'unhighlightStructure'
        },

        /* return toJSON for the places relation */
        placesToJSON: function () {
            return this.model.getRelation('places').related.models.map(function (model) {
                return _.extend(model.toJSON(), { cid: model.cid });
            });
        },

        goToStructurePage: function(event) {
            if (event.target.nodeName !== 'A') {
                window.location = this.model.get('data_url');
            }
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
        },

        serializeData: function () {
            var data = this.model.toJSON();
            data.search_term = this.search_term;

            return data;
        }

    });
});
