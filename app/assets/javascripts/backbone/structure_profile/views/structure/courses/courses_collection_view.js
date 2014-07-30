
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
            var new_html = this.$('[data-empty-courses]').html().replace('__about__', _.capitalize(this.about));
            this.$('[data-empty-courses]').html(new_html);
            if (this.collection.length == 0 && this.collection.total_not_filtered == 0) {
                this.$('[data-empty-courses]').show();
            } else {
                this.$('[data-empty-courses]').hide();
            }
        },

        onAfterShow: function onAfterShow () {
            this.iPhonizeCourseTitles();
        },

        iPhonizeCourseTitles: function iPhonizeCourseTitles () {
            var course_view_titles, offset, stop_at;
            this.$('[data-behavior=read-more]').readMore();
            this.$('[data-toggle=popover]').popover();
            course_view_titles = this.$('[data-type="course-view-title"]');
            offset             = $('#structure-profile-menu').outerHeight();
            stop_at_el         = this.$el.closest('.panel').attr('id');
            course_view_titles.each(function(index, el) {
                var data = { offsetTop: offset, oldWidth: true, stopAtEl: '#' + stop_at_el, updateOnScroll: true }
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
            var is_last = (index == (this.collection.length - 1));
            return {
                collection: new Backbone.Collection(model.get("plannings")),
                is_last   : is_last,
                about     : this.about
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
