
StructureProfile.module('Views.Structure.Courses.Privates', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PrivatesCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        childView: Module.PrivateView,
        template: Module.templateDirname() + 'privates_collection_view',

        collectionReset: function collectionReset () {
            this.trigger('privates:collection:reset', this.serializeData());
            if (this.collection.length == 0) { this.$('[data-empty-privates]').removeClass('hidden') }
        }
    });
});
