
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.CourseView,
        template: Module.templateDirname() + 'courses_collection_view',
        itemViewContainer: '[data-type=container]',


        initialize: function initialize (options) {
            this.data_url = options.data_url;
        },

        collectionEvents: {
            'reset': 'collectionReset'
        },

        collectionReset: function collectionReset () {
            var courses_count   = this.collection.length;
            var plannings_count = _.reduce(this.collection.map(function(model) { return model.get('plannings').length }), function(memo, num){ return memo + num; }, 0);
            this.trigger('courses:collection:reset', { courses_count: courses_count, plannings_count: plannings_count, plannings_not_shown: 0});

            this.render();
        },

        onItemviewMouseenter: function onItemviewMouseenter (view, data) {
            this.trigger("course:mouse:enter", data);
        },

        onItemviewMouseleave: function onItemviewMouseleave (view, data) {
            this.trigger("course:mouse:leave", data);
        },

        /*
         * Filter-breadcrumbs are rendered and hidden in the page.
         * We just move them in the course tab
         */
        moveAndShowBreadcrumbs: function moveAndShowBreadcrumbs() {
            var $breacrumb = $('[data-type=filter-breadcrumbs]');
            $breacrumb.show();
            $breacrumb.appendTo(this.$('[data-breadcrumb]'));
        },

        onAfterShow: function onAfterShow () {
            this.$('[data-behavior=read-more]').readMore();
            this.$('[data-behavior=tooltip]').tooltip();
            this.$('.panel').last().removeClass('push-half--bottom').addClass('border-none--bottom');
        },

        /* serializeData
        *
        * we need the number of courses
        * the sum of plannings of courses
        * and the data_url which the structure gave us
        * */
        serializeData: function serializeData () {
            var plannings_count   = this.collection.reduce(function (memo, model) {
                    memo                += model.get("plannings").length;
                    return memo;
                }, 0);

            return {
                courses_count: this.collection.length,
                plannings_count: plannings_count,
                plannings_not_shown: (window.coursavenue.bootstrap.total_plannings_count || 0) - plannings_count,
                data_url: this.data_url
            };
        },

        itemViewOptions: function itemViewOptions (model, index) {

            return {
                collection: new Backbone.Collection(model.get("plannings"))
            };
        },

        appendHtml: function appendHtml (collectionView, itemView, index){
            if (itemView.collection.length < 1) {
                return /* NOP */;
            }

            if (collectionView.isBuffering) {

                collectionView.elBuffer.appendChild(itemView.el);
            } else {

                collectionView.$el.append(itemView.el);
            }
        },
    });
});
