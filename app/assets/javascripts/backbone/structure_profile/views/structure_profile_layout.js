StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureProfileLayout = CoursAvenue.Views.EventLayout.extend({
        el: $("body"),
        master_region_name: 'structure',

        regions: {
            master: "#structure-region",
        },

        // @override
        // we override the layout's render function to render nothing, since
        // the body is its own element
        render: function(){
            if (this.isDestroyed){
                // a previously closed layout means we need to
                // completely re-initialize the regions
                this._initializeRegions();
            }
            if (this._firstRender) {
                // if this is the first render, don't do anything to
                // reset the regions
                this._firstRender = false;
            } else if (!this.isDestroyed){
                // If this is not the first render call, then we need to
                // re-initializing the `el` for each region
                this._reInitializeRegions();
            }

            var args = Array.prototype.slice.apply(arguments);
            var result = Marionette.renderNothing(this, args);
            return result;
        },

    });
});

