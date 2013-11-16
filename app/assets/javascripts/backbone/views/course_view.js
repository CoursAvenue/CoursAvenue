/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CourseView = Backbone.Marionette.ItemView.extend({
        template:  "backbone/templates/course_view",
        className: "push-half--top soft-half--top bordered--top",

        initialize: function(options){
            this.index = options.index;
        },

        onRender: function() {
            if (this.index == 0) {
                this.$el.removeClass("bordered--top soft-half--top");
            }
        },
    });

});
