
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.CourseView,
        template: Module.templateDirname() + 'courses_collection_view',
        itemViewContainer: '[data-type=container]',

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
