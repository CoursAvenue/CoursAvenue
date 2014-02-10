
/* just a basic marionette view */
StructureProfile.module('Views.Structure.Teachers', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.TeacherView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "teacher_view",
        tagName: "div",

        onRender: function onRender () {
            this.$el.attr("id", "prof-" + this.model.get("id"));
        },

        serializeData: function serializeData (date) {
            var data  = this.model.toJSON();
            var index = this.model.collection.indexOf(this.model);

            data.isFirst = index === 0;

            return data;
        }
    });

});
