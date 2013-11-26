FilteredSearch.module('Views.Lib', function(Module, App, Backbone, Marionette, $, _) {

    Module.EventLayout = Backbone.Marionette.Layout.extend({
        constructor: function() {
            Marionette.Layout.prototype.constructor.apply(this, arguments);
            var self = this;
            /* this should listen to events from all its regions */
            _.each(_.keys(this.regions), function(region_name) {
                var name = _.capitalize(region_name);

                self.listenTo(self[region_name], 'show', self['on' + name + 'Show']);
            });

            $(document).on('click', function (e) {
                _.each(_.keys(self.regionManager._regions), function (key) {
                    self[key].currentView.triggerMethod('click:outside', e);
                });
            });
        },

        /* add a new region to deal with a given widget
        * assumption: view.template is in_this_form */
        showWidget: function (view, options) {
            if (options === undefined) {
                options = {};
            }

            /* prepare the region and its el */
            /* view_name,     like important_filter_view */
            /* region name,   like important_filter */
            var view_name     = _.last(view.template.split('/')),
                region_name   = view_name.split('_').slice(0, -1).join('_'),
                new_region    = this.addRegion(region_name, '#' + view.cid),
                $region_hook  = $('<div/>', { id: new_region.el.slice(1) }),
                events        = options.events,
                selector      = options.selector;

            /* remember the region and listen to its show method */
            this.listenTo(this[region_name], 'show', function (view) {
                this.bindWidgetEvents(view, events, region_name);
                view.triggerMethod('after:show'); /* finally, the view may respond */
            });

            /* attach the region element to the Layout and show */
            if (selector === undefined) {
                selector = '[data-type=' + region_name.replace('_', '-') + ']';
            }

            $region_hook.appendTo(this.$el.find(selector));
            new_region.show(view);
        },

        bindWidgetEvents: function (view, events, region_name) {
            var event_suffix = _.last(region_name.split('_')),
                self = this;

            if (events === undefined) {
                events = {};
            }

            /* tie the setup method to the main region */
            /* TODO currently we are hard-coding 'structures:updated', but this
             * should be configured when the 'master region' is chosen */
            if (_.isFunction(view.setup)) {
                events.once = (events.once ? events.once : {});
                events.once['structures:updated' + ':' + event_suffix] = 'setup';
            }

            /* TODO reset and setup are probably dangerous names to take...
             * reset, in particular, already has a meaning in terms of backbone */
            if (_.isFunction(view.reset)) {
                events['structures:updated' + ':' + event_suffix] = 'reset';
            }

            /* process events that are only responded to once */
            if (events && events.once) {
                _.each(_.pairs(events.once), function (pair) {
                    var evt = pair[0];
                    var method = view[pair[1]];

                    view.listenToOnce(self, evt, method, view);
                });

                delete events.once;
            }

            /* view registers to be notified of events on layout */
            Marionette.bindEntityEvents(view, this, events);
            this.listenTo(view, 'all', this.broadcast);
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
