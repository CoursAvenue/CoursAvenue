
/* Composite
 * ---------
 *
 * This module encapsulates construction of the basic Marionette CompositeView.
 *
 * **data API**
 *
 *  - _view_: Composite
 *  - _of_: a capitalized name of some resource, in the plural, like "Teachers" or
 *    "Courses".
 *  - _and_: another resource name, to be used as the 'composite part'
 *  - _bootstrap_: The data to populate the collection on page load. If data-and
 *    was provided, then the bootstrap should be an object like `{ model: resource, collection: resources }`
 *
 * By default the Composite will use `tbody` as its itemviewContainer. This behaviour
 * can be overridden by including `data-itemviewContainer` on one of the elements in
 * the prerendered HTML or as an option on the view element.
 *
 * **usage**
 *
 * ```
 * %div{ data: { view: "Composite", of: "Students", and: "Teacher", bootstrap: { model: teacher, collection: students }}}
 * ```
 */
Daedalus.module('Views.Composite', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.Composite = Marionette.CompositeView;

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-view=" + Module.moduleName + "]").each(function (index, element) {

            var view         = buildView(element, $(element).data()),
                region_name  = Module.moduleName + _.capitalize(view.cid),
                $element     = $(element),
                regions      = {};

            regions[region_name] = "#" + view.cid;
            $element.attr("id", view.cid);

            App.addRegions(regions);
            App[region_name].show(view);

            consumeData($element);

            /* view registers to be notified of events on layout */
            Marionette.bindEntityEvents(view, App.Views, { });
            App.Views.listenTo(view, 'all', App.Views.broadcast);
        });
    });

    var consumeData = function consumeData ($element) {
        $element.removeAttr("data-view");
        $element.removeAttr("data-bootstrap");
        $element.removeAttr("data-of");
    };

    /* ***
     * ### \#buildView */
    var buildView = function buildView (element, options) {
            var $element          = $(element),
                // The options object will contain exactly $(element).data(). From
                // this we grow the identity of the Composite we are building.
                view              = options.view,
                flavor            = options.flavor,
                bootstrap         = options.bootstrap,
                resources         = options.of.toLowerCase(),
                resource          = _.singularize(resources),
                composite         = options.and,
                composite_module  = composite + 's',
                container         = options.itemviewContainer,

                // If prerendered HTML was provided, then we extract some options
                // from it. In particular, the tagName and itemviewContaineri options
                // will be attached to marked elements.
                container         = (container)? container : $element.find("[data-itemviewContainer]").get(0),
                tagName           = $element.find("[data-tagName]").get(0),

                ItemView, collection, model, Composite = Module.Composite,
                options = {};

        // After building up the model, collection and ItemView constructor,
        model      = buildModel(bootstrap.model, resource);
        collection = buildCollection(bootstrap.collection || bootstrap, resources);

        ItemView   = itemviewFor(resources, resource, $element);

        // we build up an options object to be passed into the Composite constructor.
        if (_.isElement(tagName)) {
            options.className = tagName.className;
            options.tagName   = tagName.nodeName.toLowerCase();
        }

        if (_.isElement(container)) {
            options.itemviewContainer = container.nodeName.toLowerCase();
        }

        options.tagName             = options.tagName           || "table";
        options.itemviewContainer   = options.itemviewContainer || "tbody";
        options.template            = 'backbone/structure_profile/views/' + resources + '/templates/' + resources;
        options.collection          = collection;
        options.model               = model;
        options.itemView            = ItemView;
        options.itemViewEventPrefix = "";

        if (App.Views[_.capitalize(resources)] && App.Views[_.capitalize(resources)][_.capitalize(resources)]) {
            Composite = App.Views[_.capitalize(resources)][_.capitalize(resources)];
        }

        return new Composite(options);
    };

    /* ***
     * ### \#buildModel & \#buildCollection
     *
     * Each method takes a data, which may be a json serialization
     * of an actual model, or a key to the json data in the global
     * store. After possibly getting the data from the global store,
     * we use it to construct a Model or Collection, either the one
     * referred to by the resource parameter, or the vanilla Backbone
     * version.  */
    var buildModel = function buildModel (model, resource) {
        var Model;

        if (_.isString(model)) {
            model = window.coursavenue.bootstrap[model];
        }

        Model = App.Models[resource] || Backbone.Model.extend();
        model = new Model(model || {});

        return model;
    };

    var buildCollection = function buildCollection (collection, resources) {
        var Collection;

        if (_.isString(collection)) {
            collection = window.coursavenue.bootstrap[collection];
        }

        Collection = App.Models[resources] || Backbone.Collection.extend();
        collection = new Collection(collection || {});

        return collection;
    };

    /* ***
     * ### \#itemviewFor
     * */
    var itemviewFor = function itemviewFor (resources, resource, element) {
        var ItemView, itemview_options = {},
            itemviewTagName = $(element).find("[data-itemviewTagName]").get(0);

        // If App.Views[resources][resource] is an ItemView, then we will
        // want to return that. Otherwise, we'll use a plain ItemView.
        if (App.Views[_.capitalize(resources)] && App.Views[_.capitalize(resources)][_.capitalize(resource)]) {
            ItemView = App.Views[_.capitalize(resources)][_.capitalize(resource)];
        } else {
            ItemView = Marionette.ItemView;
        }

        // The prerendered HTML should override whatever defaults the itemview
        // we found might have. So if the HTML contained an element marked as
        // the itemviewTagName, we'll use its class and node names.
        if (_.isElement(itemviewTagName)) {
            itemview_options.className = itemviewTagName.className;
            itemview_options.tagName   = itemviewTagName.nodeName.toLowerCase();
        }

        // Otherwise, we will use the itemview's own tagName, or just "tr" if
        // we are going with the default itemview (since this is a composite view).
        itemview_options.tagName  = itemview_options.tagName  || "tr";
        itemview_options.template = 'backbone/structure_profile/views/' + resources + '/templates/' + resource;

        // Finally we extend the ItemView with whatever options we discovered
        ItemView                  = ItemView.extend(itemview_options);

        return ItemView;
    };

}, undefined);


