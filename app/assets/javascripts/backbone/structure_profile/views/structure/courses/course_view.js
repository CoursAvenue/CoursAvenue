/* just a basic marionette view */
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.CourseView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "course_view",
        tagName: "div",

        onRender: function onRender () {
            this.$el.attr("id", "cours-" + this.model.get("id"));
        },

        serializeData: function serializeData (date) {
            var data  = this.model.toJSON();
            var index = this.model.collection.indexOf(this.model);

            data.isFirst = index === 0;

            return data;
        }
    });

});
