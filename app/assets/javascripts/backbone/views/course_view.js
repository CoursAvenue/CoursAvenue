/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CourseView = Backbone.Marionette.ItemView.extend({
        template:  "backbone/templates/course_view",
        tagName:   "table",
        className: "white-box table--striped table--data push-half--top flush--bottom",

        events: {
          'click': 'handleClick'
        },

        handleClick: function () {
        }
    });

});
