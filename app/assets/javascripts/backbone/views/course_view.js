/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Views.CourseView = Backbone.Marionette.CompositeView.extend({
        template:  "backbone/templates/course_view",
        className: "push-half--top soft-half--top bordered--top",
        itemView: Backbone.Marionette.ItemView.extend({
            template: "backbone/templates/plannings_view",
            tagName: 'tr',
            attributes: {
                'data-type': 'line-item'
            }
        }),
        itemViewContainer: 'tbody',

        initialize: function(options){
            this.index = options.index;
            this.collection = new Backbone.Collection(_.map(options.model.get("plannings"), function (data) {
                return new Backbone.Model(data);
            }));
        },

        onRender: function() {
            if (this.index == 0) {
                this.$el.removeClass("bordered--top soft-half--top");
            }
        },

        events: {
            'mouseenter [data-type=line-item]': 'select',
            'mouseleave [data-type=line-item]': 'deselect',
        },

        select: function (e) {
            $(e.currentTarget).toggleClass('active');
            this.trigger('selected', this.model.toJSON()); // TODO should not expose the whole model
        },

        deselect: function (e) {
            $(e.currentTarget).toggleClass('active');
            this.trigger('deselected', this.model.toJSON()); // TODO should not expose the whole model
        },

    });

});
