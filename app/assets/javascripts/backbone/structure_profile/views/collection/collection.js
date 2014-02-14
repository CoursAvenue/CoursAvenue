// Collection
// ----------
//
// This module encapsulates construction of the basic Marionette CollectionView.
//
// **data API**
//
//  - _view_: Collection
//  - _of_: a capitalized name of some resource, in the plural, like "Teachers" or
//    "Courses".
//  - _bootstrap_: The data to populate the collection on page load.
//
// **usage**
//
//```
//#structure-tabs{ data: { view: "Collection", of: "Teachers", bootstrap: @model.to_json }
//```
StructureProfile.module('Views.Collection', function(Module, App, Backbone, Marionette, $, _, undefined) {

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-view=Collection]").each(function (index, element) {
            var $element     = $(element),
                view         = $element.data("view"),
                bootstrap    = $element.data("bootstrap"),
                flavor       = $element.data("flavor"),
                resource     = $element.data("of"),
                tagName      = $element.children().first()[0].nodeName.toLowerCase(),
                className    = $element.children().first().attr("class"),
                template     = $element.data("template")? Module.templateDirname() + $element.data("template") : undefined,

                view         = buildView(view, flavor, {
                    template:  template,
                    bootstrap: bootstrap,
                    resource:  resource,
                    tagName:   tagName,
                    className: className
                }),
                region_name  = 'Collection' + _.capitalize(view.cid),
                regions      = {};

            regions[region_name] = "#" + view.cid;
            $element.attr("id", view.cid);

            App.addRegions(regions);
            App[region_name].show(view);

            consumeData($element);
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
    var buildView = function buildView (view, flavor, options) {
        // buildView adds some attributes commonly used in templates
        if (options.bootstrap.length > 0) {
            options.bootstrap[0].isFirst = (options.bootstrap[0].isFirst === undefined)? true : options.bootstrap[0].isFirst;
        }

        var result,
            // Widgets might have a model/widgets collection or a views/widgets/widget itemview
            module         = options.resource,
            resources      = options.resource.toLowerCase(),
            resource       = _.singularize(resources),
            template_name  = (options.template)? options.template : resource,
            Collection     = App.Models[resources] || Backbone.Collection.extend({
                tagName:   options.tagName,
                className: options.className

            }), ItemView, collection, itemView;

        collection = new Collection(options.bootstrap);

        // if there is a custom itemView for teachers, use that
        if (App.Views[Module] && App.Views[Module][_.capitalize(resource)]) {
            ItemView = App.Views[Module][_.capitalize(resource)];
        } else {
            ItemView = Marionette.ItemView;
        }

        // if we are using a generic item view, extend it to use the template
        if (Marionette.ItemView === ItemView) {
            ItemView       = ItemView.extend({
                template: 'backbone/structure_profile/views/' + resources + '/templates/' + template_name,
                tagName: 'li'
            });
        }

        options.collection = collection;
        options.itemView   = ItemView;

        return new Marionette.CollectionView(options);
    };

}, undefined);


