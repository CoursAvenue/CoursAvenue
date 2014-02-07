/* just a basic marionette view */
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.CourseView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "course_view",
        tagName: "div",

        onRender: function () {
            this.$el.attr("id", "cours-" + this.model.get("id"));

        },

        events: {
          'click': 'handleClick'
        },

        handleClick: function () {
          window.location = window.location.protocol + '//' + window.location.host + '/' + this.model.get('comment_url');
        },

        serializeData: function (date) {
            var data  = this.model.toJSON();
            var index = this.model.collection.indexOf(this.model);

            data.isFirst = index === 0;

            return data;
        }
    });

});
