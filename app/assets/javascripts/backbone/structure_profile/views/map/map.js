Daedalus.module('Views.Map', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.GoogleMap = CoursAvenue.Views.Map.GoogleMap.GoogleMapsView.extend({

        /* ***
        * ### \#exciteMarkers
        *
        * Event handler for `itemview:course:hovered`, as such it expects
        * a view. The view's model should have a location, and if the location
        * matches this marker's location it will get excited. */
        exciteMarkers: function(view) {
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
        },

        events: {
            ":course:mouseenter": "exciteMarkers",
            ":course:mouseleave": "exciteMarkers"
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

        // if we are using a generic item view, extend it to use the template
     // itemview_options.template = 'backbone/structure_profile/views/' + resources + '/templates/' + template_name;
     // ItemView                  = ItemView.extend(itemview_options);

        var bounds         = { lat: 48.8538177, lng: 2.3815018 };

        options.collection = collection;
        options.markerView = MarkerView;
        options.mapOptions = {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        };
        options.infoBoxOptions = {
            infoBoxClearance: new google.maps.Size(100, 100)
        };

        return new Module.GoogleMap(options);
    };

}, undefined);


