
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = Marionette.CompositeView.extend({
        childView: Module.CourseView,
        template: Module.templateDirname() + 'courses_collection_view',
        childViewContainer: '[data-type=container]',

        initialize: function initialize (options) {
            this.about       = options.about;
            this.about_genre = options.about_genre;
            this.data_url    = options.data_url;
        },

        collectionEvents: {
            'reset': 'collectionReset'
        },

        collectionReset: function collectionReset () {
            this.trigger('courses:collection:reset', this.serializeData());
            if (this.collection.length == 0) { this.$('[data-empty-courses]').removeClass('hidden') }
        },

        onChildviewMouseenter: function onChildviewMouseenter (view, data) {
            this.trigger("course:mouse:enter", data);
        },

        onChildviewMouseleave: function onChildviewMouseleave (view, data) {
            this.trigger("course:mouse:leave", data);
        },

        onChildviewRegister: function onChildviewRegister (view, data) {
            this.trigger("planning:register", data);
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

        /* serializeData
        *
        * we need the number of courses
        * the sum of plannings of courses
        * and the data_url which the structure gave us
        * */
        serializeData: function serializeData () {
            return {
                courses_count     : this.collection.length,
                data_url          : this.data_url,
                about             : this.about,
                about_genre       : this.about_genre
            };
        },

        childViewOptions: function childViewOptions (model, index) {
            var is_last = (index == (this.collection.length - 1));
            return {
                collection : new Backbone.Collection(model.get("plannings")),
                is_last    : is_last,
                about      : this.about,
                about_genre: this.about_genre
            };
        },

        attachHtml: function attachHtml (collectionView, childView, index){
            if (collectionView.isBuffering) {
                collectionView.elBuffer.appendChild(childView.el);
            } else {
                collectionView.$el.append(childView.el);
            }
        }
    });
});
