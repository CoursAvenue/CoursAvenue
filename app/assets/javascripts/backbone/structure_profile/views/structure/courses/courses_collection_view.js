
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
            this.trigger('courses:collection:reset', this.serializeData());
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

        onRender: function onRender () {
            // this.$('[data-behavior=read-more]').readMore();
            // Visual improvement for the course list
            this.$('.panel').last().removeClass('push-half--bottom').addClass('border-none--bottom');
            if (this.collection.length == 0) {
                this.$('[data-empty-courses]').show();
            } else {
                this.$('[data-empty-courses]').hide();
            }
        },

        onAfterShow: function onAfterShow () {
            this.$('[data-behavior=read-more]').readMore();
        },

        /* serializeData
        *
        * we need the number of courses
        * the sum of plannings of courses
        * and the data_url which the structure gave us
        * */
        serializeData: function serializeData () {
            var plannings_count   = this.collection.reduce(function (memo, model) {
                    memo += model.get("plannings").length;
                    return memo;
                }, 0);
            return {
                courses_count: this.collection.length,
                plannings_count: plannings_count,
                total_not_filtered:   (this.collection.total_not_filtered || 0) - plannings_count,
                data_url: this.data_url
            };
        },

        itemViewOptions: function itemViewOptions (model, index) {

            return {
                collection: new Backbone.Collection(model.get("plannings"))
            };
        },

        appendHtml: function appendHtml (collectionView, itemView, index){
            if (collectionView.isBuffering) {
                collectionView.elBuffer.appendChild(itemView.el);
            } else {
                collectionView.$el.append(itemView.el);
            }
        },
    });
});
