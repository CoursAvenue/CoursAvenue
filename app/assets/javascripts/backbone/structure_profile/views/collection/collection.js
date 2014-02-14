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
                template     = $element.data("template")? Module.templateDirname() + $element.data("template") : undefined,

                view         = buildView(view, flavor, {
                    template: template,
                    bootstrap: bootstrap,
                    resource: resource
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

    var buildView = function buildView (view, flavor, options) {
        options.bootstrap[0].isFirst = true;

        var result,
            template       = (options.template)? options.template : options.resource.toLowerCase(),
            collection     = new Backbone.Collection(options.bootstrap),
            itemView       = Marionette.ItemView.extend({
                template: 'backbone/structure_profile/views/' + template + '/templates/' + template
            });

        options.collection = collection;
        options.itemView   = itemView;

        if (options.template === undefined) {
            delete options.template;
        }

        if (flavor && Module.Flavors[flavor]) {
            result = new Module.Flavors[flavor][view](options);
        } else {
            result = new Marionette.CollectionView(options);
        }

        return result;
    };

}, undefined);


