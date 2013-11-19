
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* RelationalAccordionItemview
    *  - used to populate accordion views for collections of relational models
    *  - can provide accordion action for multiple relations on the model
    *  - doesn't need to know what relations exist on the model
    *    - naming conventions are used to build the views on demand */
    Views.RelationalAccordionItemView = Views.AccordionItemView.extend({

        loaderTemplate: '<div class="loading-indicator" style="height: 60px;"></div>',

        /* When a button is clicked, accordionControl arranges for a
        *  relation with the given name to be displayed, either by
        *  switching between tabs on the current structure_view or by
        *  deferring to the "accordionOpen" method on super */
        /* in order for accordionControl to work, you need:
        *   - a model, such as "factory", with a relation, such as "widgets"
        *   - a backend that returns the right stuff: of course
        *   - a button in templates/factory_view, like this:
        *       <button data-type="accordion-control" data-value="widgets">Whoa!</button>
        *   - two templates: widget_view and a widgets_collection_view
        *   - a view class: widget_view
        *   - the view that is created is a composite view
        *     - if you want some data on the composite part of the view,
        *       use data-attributes to define a space separated list of
        *       model attributes to be used by the composite view.
        *
        *         <button data-attributes="url count bob" data-type="accordion-control" data-value="widgets">Whoa!</button> */
        accordionControl: function (e) {
            e.preventDefault();

            var value      = $(e.currentTarget).data('value'),
                self       = this,
                attributes = ($(e.currentTarget).data('attributes') ? $(e.currentTarget).data('attributes').split(' ') : {});

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[value] === undefined) {
                self.showLoader(value);
                /* wait for asynchronous fetch of models before adding region */
                this.model.fetchRelated(value, { data: { search_term: this.search_term }}, true)[0].then(function () {
                    self.createRegionFor(value, attributes);
                    self.accordionToggle(value);
                    self.hideLoader();
                });
            } else {
                this.accordionToggle(value);
            }

            return false;
        },

        /* either switch between tabs on the structure, or defer to
        *  the accordion action */
        accordionToggle: function (value) {
            var closing = (this.active_region === value),
                button  = this.$('[data-value=' + value + ']'),
                active_region_button;

            if (button.data('wrapper')) {
                button.closest(button.data('wrapper')).toggleClass('active');
            } else {
                button.toggleClass('active');
            }

            if (closing) {
                this.accordionClose();
                this[this.active_region].currentView.$el.attr('data-type', '');

            } else { // we may be opening or switching

                if (this.active_region) {
                /* we are switching */
                    this[this.active_region].$el.find('[data-type=accordion-data]').hide();
                    this[this.active_region].currentView.$el.attr('data-type', '');
                    active_region_button = this.$('[data-value=' + this.active_region + ']');
                    if (active_region_button.data('wrapper')) {
                        active_region_button.closest(active_region_button.data('wrapper')).toggleClass('active');
                    } else {
                        active_region_button.toggleClass('active');
                    }

                    this[value].currentView.$el.attr('data-type', 'accordion-data');
                } else {
                /* both tabs are closed */
                    this[value].currentView.$el.attr('data-type', 'accordion-data');

                }

                /* try to unfold something */
                if (this.accordionOpen() === false) {
                /* we are switch between regions */
                    this[value].$el.find('[data-type=accordion-data]').show();
                }
            }

            this.active_region = (closing ? undefined : value);
        },

        showLoader: function(value) {
            var closing = (this.active_region === value);
            if (!this.$loader) {
                this.$loader = $(this.loaderTemplate).hide();
                this.$el.append(this.$loader);
            }
            if (!closing) {
                this.$loader.slideDown();
            }
        },

        hideLoader: function(value) {
            this.$loader.slideUp();
        },

        /* given a string, find the relation on the model with that name
        *  and create a region, and a composite view. Data for the composite
        *  view is grabbed from the structure, based on strings passed in
        *  an array. The collection is models on a relation on structure. */
        createRegionFor: function (object_name, attribute_strings) {
            var singular = object_name.slice(0, -1),
                self = this;

            /* collect some information to pass in to the compositeview */
            var data = _.inject(attribute_strings, function (memo, attr) {
                memo[attr] = self.model.get(attr);

                return memo;
            }, {});

            this.addRegion(object_name, "#" + object_name + this.cid);
            this.regions[object_name] = '#' + object_name + this.cid;
            this.$el.append('<div id="' + object_name  + this.cid + '">');

            collection = new Backbone.Collection(this.model.get(object_name).models);

            /* an anonymous compositeView is all we need */
            // If a collection view exists, then use it, else create a generic one.
            if (Views[App.capitalize(object_name) + 'CollectionView']) {
                ViewClass = Views[App.capitalize(object_name) + 'CollectionView'];
            } else {
                ViewClass = Backbone.Marionette.CompositeView.extend({
                    template: 'backbone/templates/' + object_name + '_collection_view',

                    // The "object_name" has an 's' at the end, that's what the slice is for
                    itemView: Views[App.capitalize(singular) + 'View'],
                    itemViewContainer: '[data-type=container]'
                });
            }

            view = new ViewClass({
                collection: collection,
                model: new Backbone.Model(data),
                attributes: {
                    'data-type': 'accordion-data',
                    'style':     'display:none'
                }
            });
            this[object_name].show(view);
        },
    });
});
