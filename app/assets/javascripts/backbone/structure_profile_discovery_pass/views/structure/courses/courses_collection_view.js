
StructureProfileDiscoveryPass.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CoursesCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        template: Module.templateDirname() + 'courses_collection_view',
        itemView: Module.CourseView,

        onItemviewRegister: function onItemviewRegistration (view, data) {
            this.trigger("planning:register", data);
        },
    });

}, undefined);
