FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.SearchWidgetsLayout = Backbone.Marionette.Layout.extend({
        template: 'backbone/templates/search_widgets_layout_view',

        regions: {
            results: "#search-results",
        },

        widgets: [],

        /* add a new region to deal with a given widget
        * assumption: view.template is in_this_form */
        showWidget: function (view, events, dom_query) {
            if (dom_query === undefined) {
                dom_query = '#widgets-container';
            }

            /* prepare the region and its el */
            var region_name = _.last(view.template.split('/')),
                new_region = this.addRegion(region_name, '#' + view.cid),
                $region_hook = $('<div/>', { id: new_region.el.slice(1) });

            /* remember the region and listen to its show method */
            this.listenTo(this[region_name], 'show', function (view) {

                /* view registers to be notified of events on layout */
                Marionette.bindEntityEvents(view, this, events);
                this.listenTo(view, 'all', this.broadcast);

                view.triggerMethod('after:show'); /* finally, the view may respond */
            });

            /* attach the region element to the Layout and show */
            $region_hook.appendTo(this.$el.find(dom_query));
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

        /* fires after the main region is first shown */
        onResultsShow: function(view) {
            console.log("EVENT  SearchWidgetsLayout->resultsShow");
            var self = this;

            /* the layout broadcasts all main region events */
            this.listenTo(view, 'all', this.broadcast);

            /* the main region passes in a hash of events */
            _.each(_.pairs(view.events), function (event) {
                var key = event[0];
                var value = event[1];

                /* the view listens to the layout's broadcasts */
                view.listenTo(self, key, view[value]);
            });

            view.triggerMethod('after:show'); /* allow the view to yawn */
        },

        /* any events that come from the results region will be
        * triggered again from the layout */
        broadcast: function(e, params) {
            // for spying on the event storm
            // console.log("EVENT  SearchWidgetsLayout->broadcast: %o : %o", e, params);
            this.trigger(e, params);
        }
    });
});

