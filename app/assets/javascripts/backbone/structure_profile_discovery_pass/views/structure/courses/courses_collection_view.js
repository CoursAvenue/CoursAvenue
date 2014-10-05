
StructureProfileDiscoveryPass.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        template: Module.templateDirname() + 'courses_collection_view',
        itemView: Module.CourseView,

        onItemviewRegister: function onItemviewRegistration (view, data) {
            this.trigger("planning:register", data);
        },
        onAfterShow: function onAfterShow () {
            // Remove all the panel if we don't have any courses to show
            if (this.collection.length == 0) {
                this.$el.closest('.panel').remove();
            }
        }
    });

}, undefined);
