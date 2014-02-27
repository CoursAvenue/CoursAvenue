
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
Daedalus.module('Views.Collection', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Composite = Marionette.CompositeView;

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-view=Composite]").each(function (index, element) {
            var $element          = $(element),
                view              = $element.data("view"), // the name of the constructor
                flavor            = $element.data("flavor"), // a sub class
                bootstrap         = $element.data("bootstrap"), // data for the collection
                resource          = $element.data("of"), // used for template name, model name, etc...
                composite         = $element.data("and"), // the composite part
                container         = $element.data("itemviewContainer"),
                container         = (container)? container : $element.find("[data-itemviewContainer]").get(0),
                tagName           = $element.find("[data-tagName]").get(0),
                itemviewTagName   = $element.find("[data-itemviewTagName]").get(0),
                regions           = {},
                region_name;

            view = buildView(view, flavor, {
                bootstrap:         bootstrap,
                resource:          resource,
                composite:         composite,
                container:         container,
                tagName:           tagName,
                itemviewTagName:   itemviewTagName
            });

            region_name  = 'Collection' + _.capitalize(view.cid),

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
     * the generic collection will try to use the resource name to find
     * existing collections, templates, and itemViews. If given the name
     * "Widgets" is till look for,
     *
     *     a collection in /model/widgets.js
     *     an itemView  in /views/widgets/widget
     *     a template   in /views/widgets/templates/widget
     *
     * failing to find any of these, the collection will use a plain
     * collection or itemView. If it fails to find a template it will
     * complain.
     */
    var buildView = function buildView (view, flavor, options) {
        // buildView adds some attributes commonly used in templates

        var result,
            // Widgets might have a model/widgets collection or a views/widgets/widget itemview
            resources      = options.resource.toLowerCase(),
            resource       = _.singularize(resources),
            template_name  = (options.template)? options.template : resources,
            itemview_template_name  = (options.template)? options.template : resource,
            Collection, ItemView, collection, Model, model,
            itemview_options = {};

        // build the itemviewContainer

        if (options.bootstrap.model) {
            options.model      = options.bootstrap.model;
            options.collection = options.bootstrap.collection;
        } else {
            options.collection = options.bootstrap;
        }

        // find the collection data
        if (_.isString(options.collection)) {
            options.collection = window.coursavenue.bootstrap[options.collection];
        }

        // find the model data
        if (_.isString(options.model)) {
            options.model = window.coursavenue.bootstrap[options.model];
        }

        // build the collection
        Collection = App.Models[resources] || Backbone.Collection.extend();
        collection = new Collection(options.collection || {});

        // build the model
        Model = App.Models[resource] || Backbone.Model.extend();
        model = new Collection(options.model || {});

        // if there is a custom itemView, use that
        if (App.Views[_.capitalize(resources)] && App.Views[_.capitalize(resources)][_.capitalize(resource)]) {
            ItemView = App.Views[_.capitalize(resources)][_.capitalize(resource)];
        } else {
            ItemView = Marionette.ItemView;
        }


        // grab the tagName, itemviewContainer, and itemviewTagName
        if (_.isElement(options.tagName)) {
            options.className = options.tagName.className;
            options.tagName   = options.tagName.nodeName.toLowerCase();
        }

        if (_.isElement(options.container)) {
            options.itemviewContainer = options.container.nodeName.toLowerCase();
        }

        if (_.isElement(options.itemviewTagName)) {
            itemview_options.className = options.itemviewTagName.className;
            itemview_options.tagName   = options.itemviewTagName.nodeName.toLowerCase();
        }

        options.tagName           = (options.tagName)           ? options.tagName           : "table";
        options.itemviewContainer = (options.itemviewContainer) ? options.itemviewContainer : "tbody";
        itemview_options.tagName  = (itemview_options.tagName)  ? itemview_options.tagName  : "tr";

        // if we are using a generic item view, extend it to use the template
        itemview_options.template = 'backbone/structure_profile/views/' + resources + '/templates/' + itemview_template_name;
        ItemView                  = ItemView.extend(itemview_options);

        options.template            = 'backbone/structure_profile/views/' + resources + '/templates/' + template_name;
        options.collection          = collection;
        options.model               = model;
        options.itemView            = ItemView;
        options.itemViewEventPrefix = "";

        return new Module.Composite(options);
    };

}, undefined);


