
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    /* RelationalAccordionItemview
    *  - used to populate accordion views for collections of relational models
    *  - can provide accordion action for multiple relations on the model
    *  - doesn't need to know what relations exist on the model
    *    - naming conventions are used to build the views on demand */
    Module.RelationalAccordionItemView = Module.AccordionItemView.extend({

        loaderTemplate: '<div class="loading-indicator" style="height: 60px;"></div>',

        /* When a button is clicked, accordionControl arranges for a
        *  relation with the given name to be displayed, either by
        *  switching between tabs on the current structure_view or by
        *  deferring to the "accordionOpen" method on super */
        /* in order for accordionControl to work, you need:
        *   - a model, such as "factory", with a relation, such as "widgets"
        *   - a backend that returns the right stuff: of course
        *   - a button in templates/factory_view, like this:
        *       <button data-behavior="accordion-control" data-model="widget">Whoa!</button>
        *   - two templates: widget_view and a widgets_collection_view
        *   - a view class: widget_view
        *   - the view that is created is a composite view
        *     - if you want some data on the composite part of the view,
        *       use data-attributes to define a space separated list of
        *       model attributes to be used by the composite view.
        *
        *         <button data-attributes="url count bob" data-behavior="accordion-control" data-model="widget">Whoa!</button> */
        accordionControl: function (e) {
            e.preventDefault();

            var model_name      = $(e.currentTarget).data('model'), // the singular model
                relation_name   = model_name + 's',
                collection_name = relation_name + '_collection',
                collection_slug = collection_name.replace('_', '-'),
                self            = this,
                attributes      = ($(e.currentTarget).data('attributes') ? $(e.currentTarget).data('attributes').split(' ') : {});

            /* if no region exists on the structure view, then we need to
            *  fetch the relation, and create a region for it */
            if (this.regions[collection_name] === undefined) {
                self.showLoader(collection_name);
                /* wait for asynchronous fetch of models before adding region */
                // this.model.fetchRelated(relation_name, { data: { search_term: this.search_term }}, true)[0].then(function () {
                this.model.get(relation_name).fetch({ data: { search_term: this.search_term }}).then(function () {
                    self.createRegionFor(relation_name, attributes);
                    self.accordionToggle(collection_name, model_name);
                    self.hideLoader();
                });
            } else {
                this.accordionToggle(collection_name, model_name);
            }

            return false;
        },

        /* either switch between tabs on the structure, or defer to
        *  the accordion action */
        accordionToggle: function (collection_name, model_name) {
            var closing       = (this.active_region === collection_name),
                active_model, active_region_button;

            this.toggleButtonForModel(model_name);

            if (closing) {
                this.accordionClose();
                this[this.active_region].currentView.$el.attr('data-behavior', '');

            } else { // we may be opening or switching

                if (this.active_region) {
                /* we are switching */
                    active_model = _.first(this.active_region.split('_')).slice(0, -1);
                    this.toggleButtonForModel(active_model);

                    this[this.active_region].$el.find('[data-behavior=accordion-data]').hide();
                    this[this.active_region].currentView.$el.attr('data-behavior', '');
                    this[collection_name].currentView.$el.attr('data-behavior', 'accordion-data');
                } else {
                /* both tabs are closed */
                    this[collection_name].currentView.$el.attr('data-behavior', 'accordion-data');

                }

                /* try to unfold something */
                if (this.accordionOpen() === false) {
                /* we are switch between regions */
                    this[collection_name].$el.find('[data-behavior=accordion-data]').show();
                }
            }

            this.active_region = (closing ? undefined : collection_name);
            if (this.active_region && typeof(this.onAccordeonOpen) === 'function') {
                this.onAccordeonOpen();
            }
        },

        toggleButtonForModel: function (model_name) {
            var button = this.$('[data-model=' + model_name + ']');

            if (button.data('wrapper')) {
                button = button.closest(button.data('wrapper'));
            }

            button.toggleClass('active');
        },

        showLoader: function(collection_name) {
            var closing = (this.active_region === collection_name);
            if (!this.$loader) {
                this.$loader = $(this.loaderTemplate).hide();
                this.$el.append(this.$loader);
            }
            if (!closing) {
                this.$loader.slideDown();
            }
        },

        hideLoader: function() {
            this.$loader.slideUp();
        },

        /* any implementation of RelationalAccordionView must do this */
        /*    this.getModuleForRelation = _.bind(this.getModuleForRelation, Module); */
        getModuleForRelation: function (relation) {
            var keys = this.modulePath.split('.')
            keys.push(_.capitalize(relation));

            var Relation = _.inject(keys, function (memo, key) {
                if (memo[key]) {
                    memo = memo[key];
                }

                return memo;

            }, this.app);

            return Relation;
        },

        /* given a string, find the relation on the model with that name
        *  and create a region, and a composite view. Data for the composite
        *  view is grabbed from the structure, based on strings passed in
        *  an array. The collection is models on a relation on structure. */
        createRegionFor: function (relation_name, attribute_strings) {
            var model_name   = relation_name.slice(0, -1),
                Relations    = this.getModuleForRelation(relation_name), // the module in which the relation views will be
                self         = this, collection, ViewClass, view;

            /* collect some information to pass in to the compositeview */
            var data = _.inject(attribute_strings, function (memo, attr) {
                memo[attr] = self.model.get(attr);

                return memo;
            }, {});

            this.$el.append('<div data-type="' + relation_name + '-collection">');

            collection = new Backbone.Collection(this.model.get(relation_name).models);

            /* an anonymous compositeView is all we need */
            // If a collection view exists, then use it, else create a generic one.
            if (Relations[_.capitalize(relation_name) + 'CollectionView']) {
                ViewClass = Relations[_.capitalize(relation_name) + 'CollectionView'];
            } else {
                ViewClass = Backbone.Marionette.CompositeView.extend({
                    template: Relations.templateDirname() + relation_name + '_collection_view',

                    childView: Relations[_.capitalize(model_name) + 'View'],
                    childViewContainer: '[data-type=container]'
                });
            }

            view = new ViewClass({
                collection: collection,
                model: new Backbone.Model(data),
                attributes: {
                    'data-behavior': 'accordion-data',
                    'style':         'display:none'
                }
            });

            this.showWidget(view);
        },
    });
});
