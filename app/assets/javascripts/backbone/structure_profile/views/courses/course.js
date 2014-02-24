
StructureProfile.module('Views.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Course = Marionette.ItemView.extend({

        initialize: function () {

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
