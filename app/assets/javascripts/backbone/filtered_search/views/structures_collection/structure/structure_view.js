/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.RelationalAccordionItemView.extend({
        template: Module.templateDirname() + 'structure_view',
        tagName: 'li',
        className: 'push-half--bottom',
        attributes: {
            'data-type': 'structure-element'
        },

        initialize: function(options) {
            this.$el.data('url', options.model.get('data_url'));
            this.$el.data('query-url', options.model.get('query_url'));

            /* the structure view needs to know how it is being filtered */
            if (options.search_term) {
                this.search_term = options.search_term;
            }

            /* any implementation of RelationalAccordionView must do this */
            this.getModuleForRelation = _.bind(this.getModuleForRelation, Module);
        },

        onRender: function() {
            this.highlight();
        },

        onAccordeonOpen: function() {
            this.highlight();
        },

        /* TODO accordioncontrol is defined on the parent, so it feels
        * dirty to have the click handled here. However, it seems that
        * the child's events hash overrides the parent's hash by default */
        events: {
            'click':                                   'goToStructurePage',
            'click [data-behavior=accordion-control]': 'accordionControl',
            'mouseenter':                              'highlightStructure',
            'mouseleave':                              'unhighlightStructure'
        },

        /* return toJSON for the places relation */
        placesToJSON: function () {
            return this.model.getRelation('places').related.models.map(function (model) {
                return _.extend(model.toJSON(), { cid: model.cid });
            });
        },

        goToStructurePage: function(event) {
            // Checking the parent prevent from clicking on an icon that is nested within a link element.
            if (event.target.nodeName !== 'A'
                && $(event.target).parent('a').length === 0
                && $(event.target).closest('[data-el="structure-view"]').length > 0) {
                if (event.metaKey || event.ctrlKey) { // Open in new window if user pushes meta or ctrl key
                    window.open(this.model.get('data_url'));
                } else {
                    window.location = this.model.get('data_url');
                }
            }
        },
        /* a structure was selected, so return the places JSON
        * TODO would it be nicer is this just returned the whole model's
        * json, including the places relation?
        * TODO: this todo is referenced in trello: https://trello.com/c/z8OddcYs */
        highlightStructure: function (e) {
            this.trigger('highlighted', this.placesToJSON());
        },

        unhighlightStructure: function (e) {
            this.trigger('unhighlighted', this.placesToJSON());
        },

        highlight: function() {
            if (this.search_term) {
                this.$el.highlight(this.search_term);
            }
        },

        serializeData: function () {
            var data = this.model.toJSON();
            data.search_term = this.search_term;

            return data;
        }
    });
});
