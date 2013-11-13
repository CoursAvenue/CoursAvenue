FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.SearchWidgetsLayout = Backbone.Marionette.Layout.extend({
        template: 'backbone/templates/search_widgets_layout_view',
        className: 'relative',

        regions: {
            results: "#search-results",
        },

        widgets: [],

        onShow: function() {
            FilteredSearch.$loader().fadeOut('slow');
        },

        /* add a new region to deal with a given widget
        * assumption: view.template is in_this_form */
        showWidget: function (view, events, dom_query) {
            if (dom_query === undefined) {
                dom_query = '#widgets-container';
            }

            /* prepare the region and its el */
            /* view_name,     like important_filter_view */
            /* region name,   like important_filter */
            /* region suffix, like filter */
            var view_name     = _.last(view.template.split('/')),
                region_name   = view_name.split('_').slice(0, -1).join('_'),
                region_suffix = _.last(region_name.split('_')),
                new_region    = this.addRegion(region_name, '#' + view.cid),
                $region_hook  = $('<div/>', { id: new_region.el.slice(1) }),
                self          = this;

            /* remember the region and listen to its show method */
            this.listenTo(this[region_name], 'show', function (view) {

                /* tie the setup method to the main region */
                if (_.isFunction(view.setup)) {
                    events.once = (events.once ? events.once : {});
                    events.once['structures:updated' + ':' + region_suffix] = 'setup';
                }

                /* process events that are only responded to once */
                if (events.once) {
                    _.each(_.pairs(events.once), function (pair) {
                        var evt = pair[0];
                        var method = view[pair[1]];

                        view.listenToOnce(self, evt, method, view);
                    });
                }

                delete events.once;

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
                var name = App.capitalize(region_name);

                self.listenTo(self[region_name], 'show', self['on' + name + 'Show']);
            });

            $(document).on('click', function (e) {
                _.each(_.keys(self.regionManager._regions), function (key) {
                    self[key].currentView.triggerMethod('click:outside', e);
                });
            });

        },

        /* fires after the main region is first shown */
        onResultsShow: function(view) {
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
            this.trigger(e, params);
        }
    });
});

