
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.CourseView,
        template: Module.templateDirname() + 'courses_collection_view',
        itemViewContainer: '[data-type=container]',

        summaryTemplate: Module.templateDirname() + 'summary',

        ui: {
            '$summary': '[data-summary]',
            '$button': '[data-type=button]'
        },

        events: {
            'click @ui.$button': 'announceSummaryClicked'
        },

        collectionEvents: {
            'change': 'onRender'
        },

        onItemviewMouseenter: function (view, data) {
            this.trigger("course:mouse:enter", data);
        },

        onItemviewMouseleave: function (view, data) {
            this.trigger("course:mouse:leave", data);
        },

        onRender: function () {
            var html = Marionette.Renderer.render(this.summaryTemplate, this.serializeData());
            this.ui.$summary.html(html);
        },

        announceSummaryClicked: function announceSummaryClicked (e) {
            e.preventDefault();

            this.trigger("summary:clicked");
        },

        /* serializeData
        *
        * we need the number of courses
        * the sum of plannings of courses
        * and the data_url which the structure gave us
        * */
        serializeData: function () {
            var plannings_not_shown = 0,
                plannings_count   = this.collection.reduce(function (memo, model) {
                    memo                += model.get("plannings").length;
                    plannings_not_shown += model.get("plannings_not_shown");

                    return memo;
                }, 0);

            return {
                courses_count: this.collection.length,
                plannings_count: plannings_count,
                plannings_not_shown: plannings_not_shown,
                data_url: this.data_url
            };
        },

        itemViewOptions: function itemViewOptions (model, index) {

            return {
                collection: new Backbone.Collection(model.get("plannings"))
            };
        },

        appendHtml: function(collectionView, itemView, index){
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
