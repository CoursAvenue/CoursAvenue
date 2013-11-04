/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {


    Views.StructureView = Views.AccordionItemView.extend({
        template: 'backbone/templates/structure_view',
        tagName: 'li',
        className: 'structure-item push-half--bottom',
        attributes: {
            'data-type': 'structure-element hard'
        },

        initialize: function(options) {
            this.$el.data('url', options.model.get('data_url'));
        },

        events: {
            'click [data-type=accordion-control]': 'accordionControl',
            'mouseenter':                          'highlightStructure',
            'mouseleave':                          'unhighlightStructure'
        },

        /* When a button is clicked, accordionControl arranges for a
        *  relation with the given name to be displayed, either by
        *  switching between tabs on the current structure_view or by
        *  deferring to the "accordionOpen" method on super */
        /* in order for accordionControl to work, you need:
        *   - a model with a relation, such as "widgets"
        *   - a backend that returns the right stuff: of course
        *   - a button in templates/structure_view, like this:
        *       <button data-type="accordion-control" data-value="widgets">Whoa!</button>
        *   - two templates: widget_view and a widgets_collection_view
        *
        *   The actual view classes and collection are generated below */
        accordionControl: function (e) {
            e.preventDefault();

            var value = $(e.currentTarget).data('value'),
                self = this;

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[value] === undefined) {
                /* wait for asynchronous fetch of models before adding region */
                this.model.fetchRelated(value, {}, true)[0].then(function () {
                    self.createRegionFor(value);
                    self.accordionToggle(value);
                });
            } else {
                this.accordionToggle(value);
            }

            return false;
        },

        /* either switch between tabs on the structure, or defer to
        *  the accordion action */
        accordionToggle: function (value) {
            var closing = (this.active_region === value);

            if (closing) {
                this.accordionClose();
                $('html, body').animate({
                    scrollTop: this.$el.offset().top
                }, 400);
            } else { // we may be opening or switching

                /* we are switching */
                if (this.active_region) {
                    this[this.active_region].$el.find('[data-type=accordion-data]').hide();
                    this[this.active_region].currentView.$el.attr('data-type', '');
                    this[value].currentView.$el.attr('data-type', 'accordion-data');
                }

                /* we tried to switch between regions */
                if (this.accordionOpen() === false) {
                    this[value].$el.find('[data-type=accordion-data]').show();
                }
            }

            this.active_region = (closing)? undefined : value;
        },

        /* given a string, find the relation on the model with that name
        *  and create a region, and a view. Attach the view to the region */
        createRegionFor: function (value) {
            this.addRegion(value, "#" + value + this.cid);
            this.regions[value] = '#' + value + this.cid;
            this.$el.append('<div id="' + value  + this.cid + '">');

            collection = new Backbone.Collection(this.model.get(value).models);

            /* an anonymous compositeView is all we need */
            ViewClass = Backbone.Marionette.CompositeView.extend({
                template: 'backbone/templates/' + value + '_collection_view',

                // The "value" has an 's' at the end, that's what the slice is for
                itemView: Views[App.capitalize(value.slice(0, -1)) + 'View'],
                itemViewContainer: '[data-type=container]'
            });

            view = new ViewClass({
                collection: collection,
                model: new Backbone.Model({ data_url: this.model.get('data_url') }),
                attributes: {
                    'data-type': 'accordion-data',
                    'style':     'display:none'
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
