Daedalus.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMap = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({

        events: {
            ":course:mouseenter": "exciteMarkers",
            ":course:mouseleave": "exciteMarkers"
        },

        onShow: function onShow () {
            var $parent      = this.$el.parent(),
                parent_width = $parent.parent().width();

            // The sticky-full class needs to know about the parent's width,
            // so that we can css transition to it. Transitions between a
            // static value and a percentage don't work.
            $('<style>.sticky--full { transition: width 0.5s ease; width: ' + parent_width + 'px; }</style>').appendTo('head');

            // The map should always have sticky and sticky--full at the same
            // time. Whenever it gets or loses one of those classes, it should
            // get or lose the other. This is relevant during scroll, so we check
            // enforce it here.
            $(window).on("scroll", function () {
                if ($parent.hasClass("sticky")) {
                    $parent.addClass("sticky--full");

                } else if (!$parent.hasClass("sticky") && $parent.hasClass("sticky--full")) {
                    $parent.removeClass("sticky--full");
                }

                this.recenterMap();
            }.bind(this));
        },

        /* ***
         * ### \#recenterMap
         *
         * When we change the width of the map's container, we need to alert the map
         * to this by triggering resize. This will change the amount of map that is
         * shown, but won't adjust the center of the map so that it is visually centered.
         * So, in addition, we visually center the map.
         * */
        recenterMap: function recenterMap () {
            var currCenter = this.map.getCenter();

            google.maps.event.trigger(this.map, 'resize');
            this.map.setCenter(currCenter);
        },

        /* ***
        * ### \#exciteMarkers
        *
        * Event handler for `itemview:course:hovered`, as such it expects
        * a view. The view's model should have a location, and if the location
        * matches this marker's location it will get excited. */
        exciteMarkers: function exciteMarkers (view) {
            var key = view.model.get("place_id");

            if (key === null) {
                return;
            }

            _.each(this.markerViewChildren, function (child) {
                if (child.model.get("id") === key) {
                    child.toggleHighlight();

                    if (child.isHighlighted()) {
                        child.excite();
                    } else {
                        child.calm();
                    }
                }
            });
        }
    });

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-view=Map]").each(function (index, element) {
            var $element     = $(element),
                view         = $element.data("view"), // the name of the constructor
                bootstrap    = $element.data("bootstrap"), // data for the collection
                resource     = $element.data("of"), // used for template name, model name, etc...
                sample_tag   = $element.find("[data-sample-tag]")[0],
                template     = $element.data("template")? Module.templateDirname() + $element.data("template") : undefined,
                view, region_name, regions ={};

            view = buildView(view, {
                template:      template,
                bootstrap:     bootstrap,
                resource:      resource,
                tag:           sample_tag
            }),

            region_name  = 'Collection' + _.capitalize(view.cid),

            regions[region_name] = "#" + view.cid;
            $element.attr("id", view.cid);

            App.addRegions(regions);
            App[region_name].show(view);

            consumeData($element);

            /* view registers to be notified of events on layout */
            Marionette.bindEntityEvents(view, App.Views, view.events);
            App.Views.listenTo(view, 'all', App.Views.broadcast);
        });
    });

    var consumeData = function consumeData ($element) {
        $element.removeAttr("data-view");
        $element.removeAttr("data-bootstrap");
        $element.removeAttr("data-of");
    };

    // the generic collection will try to use the resource name to find
    // existing collections, templates, and itemViews. If given the name
    // "Widgets" is till look for,
    //
    //     a collection in /model/widgets.js
    //     an itemView  in /views/widgets/widget
    //     a template   in /views/widgets/templates/widget
    //
    // failing to find any of these, the collection will use a plain
    // collection or itemView. If it fails to find a template it will
    // complain.
    var buildView = function buildView (view, options) {

        var result,
            // Widgets might have a model/widgets collection or a views/widgets/widget itemview
            resources      = options.resource.toLowerCase(),
            resource       = _.singularize(resources),
            template_name  = (options.template)? options.template : resource,
            Model, Collection, MarkerView, collection,
            itemview_options = {};

        // build up the tagNames and classNames from the sample
        if (options.tag) {
            options.tagName   = options.tag.nodeName.toLowerCase();
            options.className = options.tag.className;
        }

        Model      = App.Models[resource] || Backbone.Model.extend({
            getLatLng: function() {
                var location = this.get("location"),
                    lat = location.latitude,
                    lng = location.longitude;

                return new google.maps.LatLng(lat, lng);
            }
        });

        Collection = App.Models[resources] || Backbone.Collection.extend();
        collection = new Collection(options.bootstrap || {}, { model: Model });

        // if there is a custom mapMarker, use that
        if (Module[_.capitalize(resources)] && Module[_.capitalize(resources)][_.capitalize(resource)]) {
            MarkerView = Module[_.capitalize(resources)][_.capitalize(resource)];
        } else {
            MarkerView = CoursAvenue.Views.Map.GoogleMap.MarkerView;
        }

        var center         = window.coursavenue.bootstrap.center || { lat: 0, lng: 0 };

        options.collection = collection;
        options.markerView = MarkerView;
        options.mapOptions = {
            center: new google.maps.LatLng(center.lat, center.lng)
        };
        options.infoBoxOptions = {
            infoBoxClearance: new google.maps.Size(100, 100)
        };

        return new Module.GoogleMap(options);
    };

}, undefined);


