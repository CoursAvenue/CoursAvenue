
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.CourseView,
        template: Module.templateDirname() + 'courses_collection_view',
        itemViewContainer: '[data-type=container]',

        initialize: function initialize (options) {
            this.about       = options.about;
            this.about_genre = options.about_genre;
            this.data_url    = options.data_url;
            _.bindAll(this, 'iPhonizeCourseTitles');
        },

        collectionEvents: {
            'reset': 'collectionReset'
        },

        collectionReset: function collectionReset () {
            this.trigger('courses:collection:reset', this.serializeData());
            _.delay(this.iPhonizeCourseTitles, 500);
        },

        onItemviewMouseenter: function onItemviewMouseenter (view, data) {
            this.trigger("course:mouse:enter", data);
        },

        onItemviewMouseleave: function onItemviewMouseleave (view, data) {
            this.trigger("course:mouse:leave", data);
        },

        onItemviewRegister: function onItemviewRegister (view, data) {
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

        onAfterShow: function onAfterShow () {
            this.iPhonizeCourseTitles();
        },

        iPhonizeCourseTitles: function iPhonizeCourseTitles () {
            var course_view_titles, offset, stop_at;
            this.$('[data-behavior=read-more]').readMore();
            course_view_titles = this.$('[data-type="course-view-title"]');
            offset             = $('#structure-profile-menu').outerHeight();
            stop_at_wrapper_el   = this.$el.closest('.panel').attr('id');
            course_view_titles.each(function(index, el) {
                var data = { offsetTop: offset, oldWidth: true, stopAtWrapperEl: '#' + stop_at_wrapper_el, updateOnScroll: true };
                if (index > 0) { data.pushed = '#' + course_view_titles[index - 1].id; }
                $(el).sticky(data);
            });
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
                about_genre       : this.about_genre,
                has_courses       : (this.collection.length > 0)
            };
        },

        itemViewOptions: function itemViewOptions (model, index) {
            var is_last = (index == (this.collection.length - 1));
            return {
                collection : new Backbone.Collection(model.get("plannings")),
                is_last    : is_last,
                about      : this.about,
                about_genre: this.about_genre
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
