CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.EventLayout = Backbone.Marionette.Layout.extend({
        constructor: function(options) {
            /* NORMALLY events passed in as options to the constructor override
            * those set on the class. We haven't been using the options has that
            * way, and in particular for EventLayout this is a detriment. We
            * want to be able to:
            *
            *  - extend EventLayout, and include an events hash
            *  - define events as options and pass them in to the constructor
            *
            * Hence we extend this.events with options.events
            *
            * see userProfileView's events hash, and then
            * the events hash in UserProfilesCollectionView
            * which is used to set up the layout */

            this.layout_events = undefined;

            if (options) {
                this.layout_events = options.events;
                delete options.events; // we need Backbone to never see this...
            }

            // OK _now_ call the constructor
            Marionette.Layout.prototype.constructor.apply(this, arguments);

            var self = this;
            /* this should listen to events from all its regions */
            _.each(_.keys(this.regions), function(region_name) {
                var name = _.capitalize(region_name);

                self.listenTo(self[region_name], 'show', self['on' + name + 'Show']);
            });

            // finally, bind the layout_events if they exist
            if (this.layout_events) {
                Marionette.bindEntityEvents(this, this, this.layout_events);
            }

            /* click outside events are not broadcast so they must be
             * subscribed to with 'on' when the relevant view is initialized */
            $(document).on('click', function (e) {
                _.each(_.keys(self.regionManager._regions), function (key) {
                    var view = self[key].currentView;
                    var target_exists = $(document).find(e.target).length > 0; // is the target in the DOM

                    // if there is such a view, and there is such an element
                    // and if the element is not in the view
                    if (view && target_exists && view.$el.find(e.target).length === 0) {
                        self[key].currentView.triggerMethod('click:outside', e);
                    }
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
                selector = '[data-type=' + region_name.replace(/_/g, '-') + ']';
            }

            $region_hook.appendTo(this.$el.find(selector));
            new_region.show(view);
            this.regions[region_name] = new_region;
            /* we have to add the region here to the regions object, because
            * the addregion method only adds the region to the regionManager's
            * _regions object, not to the view's regions object. */
        },

        /* getter for virtual property */
        /* this will only get called if there are subregions that have setup
        *  or reset methods. So, it is possible to get by without a master_region_name,
        *  as is the case with accordion_view */
        getMasterRegionName: function () {
            if (this.master_region_name === undefined) {
                throw "Objects extending from EventLayout must define master_region_name."
            }

            return this.master_region_name;
        },

        bindWidgetEvents: function (view, events, region_name) {
            var event_suffix = _.last(region_name.split('_')),
                self = this;

            if (events === undefined) {
                events = {};
            }

            /* tie the setup method to the main region */
            if (_.isFunction(view.setup)) {
                events.once = (events.once ? events.once : {});
                events.once[this.getMasterRegionName() + ':updated' + ':' + event_suffix] = 'setup';
            }

            /* TODO reset and setup are probably dangerous names to take...
             * reset, in particular, already has a meaning in terms of backbone */
            if (_.isFunction(view.reset)) {
                events[this.getMasterRegionName() + ':updated' + ':' + event_suffix] = 'reset';
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
        onMasterShow: function(view) {

            // Such edge case! Amaze!
            // if the master region is showing a view that... extends EventLayout!
            // then we have problems. EventLayout hides its events hash so that
            // it can declare its DOM events and App events together. However,
            // we need it to unhide them for us here. So if view.events is missing
            // and there are layout_events, then we will treat them as the events
            // to bind for the master view
            if (view.events === undefined && view.layout_events !== undefined) {
                view.events = view.layout_events;
            }

            var self = this;

            /* the layout broadcasts all main region events */
            this.listenTo(view, 'all', this.broadcast);

            /* the main region passes in a hash of events */
            _.each(_.pairs(view.events || {}), function (event) {
                var key   = event[0];
                var value = event[1];

                /* the view listens to the layout's broadcasts */
                view.listenTo(self, key, view[value]);
            });

            view.triggerMethod('after:show'); /* allow the view to yawn */
        },

        /* any events that come from the results region will be
        * triggered again from the layout */
        broadcast: function(e, params) {
            if (e === "click:outside") {
                return;
            }
            this.trigger(e, params);
        }
    });
});
