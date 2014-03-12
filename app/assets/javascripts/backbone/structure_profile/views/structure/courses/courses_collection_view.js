
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.CourseView,
        template: Module.templateDirname() + 'courses_collection_view',
        itemViewContainer: '[data-type=container]',

        initialize: function() {
            this.collection.at(0).is_first = true;
        },

        onItemviewMouseenter: function (view, data) {
            this.trigger("course:mouse:enter", data);
        },

        onItemviewMouseleave: function (view, data) {
            this.trigger("course:mouse:leave", data);
        },

        onAfterShow: function() {
            this.$('[data-behavior=read-more]').readMore();
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
