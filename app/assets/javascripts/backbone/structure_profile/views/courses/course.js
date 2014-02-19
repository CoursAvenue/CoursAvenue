
StructureProfile.module('Views.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Course = Marionette.ItemView.extend({

        initialize: function () {

        },

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
