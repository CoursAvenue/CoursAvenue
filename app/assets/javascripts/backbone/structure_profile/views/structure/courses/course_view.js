
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = Marionette.CompositeView.extend({
        template                       : Module.templateDirname() + 'course_view',
        childView                      : Module.Plannings.PlanningView,
        childViewContainer             : '[data-type=plannings-container]',
        priceCollectionViewContainer   : '[data-type=prices-collection-container]',
        subjectsCollectionViewContainer: '[data-type=subjects-collection-container]',
        emptyView                      : Module.EmptyView,

        modelEvents: {
            'change': 'updatePlannings'
        },
        events: {
            'click [data-behavior=register-to-course]': 'registerToCourse',
            'mouseenter [data-behavior=excite-markers]': 'courseHovered',
            'mouseleave [data-behavior=excite-markers]': 'courseHoveredOut'
        },

        initialize: function initialize (options) {
            this.model.set('is_last', options.is_last);
            this.model.set('about', options.about);
            this.model.set('about_genre', options.about_genre);
            this.model.set('is_sleeping', window.coursavenue.bootstrap.meta.is_sleeping);
        },

        onRender: function onRender (options) {
            // Render prices
            var prices_collection_container = this.$(this.priceCollectionViewContainer);
            if (this.model.get('db_type') == 'Course::Training') {
                var prices_collection = new CoursAvenue.Models.PricesCollection(this.model.get('prices'));
            } else {
                var prices_collection = new CoursAvenue.Models.PricesCollection(this.model.get('price_group_prices'));
            }
            var prices_collection_view      = new Module.PricesCollectionView({ collection:  prices_collection,
                                                                                about_genre: this.model.get('about_genre'),
                                                                                about:       this.model.get('about') });
            prices_collection_view.render();
            prices_collection_container.append(prices_collection_view.el);

            // Render Subjects
            var subjects_collection_container = this.$(this.subjectsCollectionViewContainer);
            var subjects_collection           = new CoursAvenue.Models.SubjectsCollection(this.model.get('subjects'));
            var subjects_collection_view      = new CoursAvenue.Views.SubjectsCollectionView({ collection:  subjects_collection });
            subjects_collection_view.render();
            subjects_collection_container.append(subjects_collection_view.el);
        },

        /* the Course model used here as the composite part is the actual
        * course model in the structure's courses relation. However, the
        * collection of plannings is _not_ part of the structure. This means
        * that the plannings won't automagically update. So we update them
        * ourselves.
        *
        * TODO: clearly plannings should be a relation on Course... it will
        * just take a brief sojourn in serialization hell to get it done.
        * */
        updatePlannings: function updatePlannings (model) {
            this.collection.set(model.changed.plannings);
        },

        onChildviewMouseenter: function onChildviewMouseenter (view, data) {
            this.trigger("mouseenter", data);
        },

        onChildviewMouseleave: function onChildviewMouseleave (view, data) {
            this.trigger("mouseleave", data);
        },

        courseHovered: function courseHovered (options) {
            var place_ids = _.map(this.model.get('plannings'), function(planning) {
                return planning.place_id;
            });
            this.trigger("mouseenter", { place_ids: _.uniq(place_ids) });
        },

        courseHoveredOut: function courseHoveredOut (options) {
            var place_ids = _.map(this.model.get('plannings'), function(planning) {
                return planning.place_id;
            });
            this.trigger("mouseleave", { place_ids: _.uniq(place_ids) });
        },

        onChildviewRegister: function onChildviewRegister (view, data) {
            this.trigger("register", data);
        },

        registerToCourse: function registerToCourse (view, data) {
            this.trigger("register", { course_id: this.model.get('id') });
        },

        childViewOptions: function childViewOptions (model, index) {
            return {
                course: this.model.toJSON(),
                is_last: (index == (this.collection.length - 1))
            };
        },
        serializeData: function serializeData () {
            var attributes             = this.model.toJSON()
            attributes.min_price       = new CoursAvenue.Models.Price(attributes.min_price).toJSON()
            attributes.is_sleeping     = window.coursavenue.bootstrap.meta.is_sleeping;

            // If on structure planning page
            attributes.accepts_payment = false;
            if (window.coursavenue.bootstrap.structure.can_receive_payments &&
                location.pathname.match(Routes.structure_website_structure_path(window.coursavenue.bootstrap.structure.slug))) {
                attributes.accepts_payment = (this.model.get('accepts_payment') && !attributes.min_price.is_free);
            }
            return attributes;
        },

    });

}, undefined);
