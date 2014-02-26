
Daedalus.module('Views.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Course = Marionette.ItemView.extend({

        initialize: function () {

        },

        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave'
        },

        /* ***
         * Course is an itemview, but its Collection is not defined explicitly.
        * In this case, the events fire from the Course get are still received
        * by the Collection, and then emitted again with the itemview prefix.
        * The result is that the View Module will get an event like `itemview:course:hovered`.
        * This isn't a great default behavior for a standalone itemview, I'd
        * rather the Module receive just `course:hovered`. At the same time, if
        * things are starting to get complicated we will no doubt eventually
        * implement a Courses collection view explicitly, and in that case we
        * can fire whatever events we want. */
        announceEnter: function () {
            this.trigger("course:mouseenter", { place_id: this.model.get("place_id")})
        },

        announceLeave: function () {
            this.trigger("course:mouseleave", { place_id: this.model.get("place_id")})
        },

        // **attach**
        //
        // This will be added to the Module for ItemView.
        // It allows an itemview to adopt existing HTML on the page
        // rather than render a new el. The bindings defined in this
        // file, such as a click event, will be bound correctly. In
        // addition, any behaviours that were defined on the element
        // will also remain after the view is attached.
        attach: function(element){
            this.isClosed = false;
            this.triggerMethod("before:render", this);
            this.triggerMethod("item:before:render", this);

            var html     = element;

            this.$el.html(html);
            this.bindUIElements();
            this.triggerMethod("render", this);
            this.triggerMethod("item:rendered", this);

            return this;
        }

    });

}, undefined);
