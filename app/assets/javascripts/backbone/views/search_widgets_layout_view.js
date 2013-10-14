FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.SearchWidgetsLayout = Backbone.Marionette.Layout.extend({
        template: 'backbone/templates/search_widgets_layout_view',

        regions: {
            results: "#search-results",
        },

        widgets: [],

        /* add a new region to deal with a given widget
        * assumption: view.template is in_this_form */
        showWidget: function (view, events, region_name) {
            if (region_name == undefined) {
                region_name = _.last(view.template.split('/'));
            }

            /* prepare the region and its el */
            var new_region = this.addRegion(region_name, '#' + view.cid),
                $region_hook = $('<div/>', { id: new_region.el.slice(1) });

            /* remember the region and listen to its show method */
            this.widgets.push({ name: this[region_name], id: view.cid });
            this.listenTo(this[region_name], 'show', function (view) {
                console.log("EVENT  onPaginationToolShow");

                /* view registers to be notified of events on layout */
                Marionette.bindEntityEvents(view, this, events);
            });

            /* attach the region element to the Layout and show */
            $region_hook.appendTo(this.$el.find('#widgets-container'));
            new_region.show(view);
        },

        initialize: function() {
            var self = this;
            /* this should listen to events from all its regions */
            _.each(_.keys(this.regions), function(region_name) {
                var name = region_name.charAt(0).toUpperCase() + region_name.slice(1);

                self.listenTo(self[region_name], 'show', self['on' + name + 'Show']);
            });
        },

        /* fires when the structures_view is first shown */
        onResultsShow: function(view) {
            this.listenTo(view, 'all', this.broadcast);
        },

        /* any events that come from the results region will be
        * triggered again from the layout */
        broadcast: function(e, params) {
            this.trigger(e, params);
        }
    });
});

