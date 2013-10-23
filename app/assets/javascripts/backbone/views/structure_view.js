/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.PlaceView = Backbone.Marionette.ItemView.extend({
        tagName: "tr",
        template: "backbone/templates/place_view"
    });

    Views.PlacesCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/places_collection_view',
        tagName: 'table',

        itemView: Views.PlaceView,
    });

    Views.SubjectView = Backbone.Marionette.ItemView.extend({
        tagName: "tr",
        template: "backbone/templates/subject_view"
    });

    Views.SubjectsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/subjects_collection_view',
        tagName: 'table',

        itemView: Views.SubjectView,
    });

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
            'click button[data-type=accordion-control]': 'accordionControl',
            'mouseenter': 'highlightStructure',
            'mouseleave': 'unhighlightStructure'
        },

        /* build an appropriate collection and populate an appropriate view */
        accordionControl: function (e) {
            e.preventDefault();
            console.log("EVENT  StructureView->accordionControl")
            /* we are using values like place, which are already on the model,
            *  for now, but later there will need to be some data fetching
            *  going on */

            var value = $(e.currentTarget).data('value');

            /* we need to build the region */
            if (this.regions[value] === undefined) {
                this.createRegionFor(value);
            }

            /* replace the existing active region */
            if (this.active_region && this.active_region !== value) {
                this[this.active_region].$el.find('[data-type=accordion-data]').hide();
                this[this.active_region].currentView.$el.attr('data-type', '');
                this[value].currentView.$el.attr('data-type', 'accordion-data');
            }

            /* we tried to switch between regions */
            if (this.accordionOpen() === false) {
                this[value].$el.find('[data-type=accordion-data]').show();
            }

            this.active_region = value;

            return false;
        },

        createRegionFor: function (value) {
            this.addRegion(value, "#" + value);
            this.regions[value] = '#' + value;
            this.$el.append('<div id="' + value + '">');

            collection = new Backbone.Collection(this.model.get('places').models);
            view_class = Views[App.capitalize(value) + 'CollectionView'];
            view = new view_class({
                collection: collection,
                attributes: {
                    'data-type': 'accordion-data',
                    'style': 'display:none'
                }
            });

            this[value].show(view);
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
