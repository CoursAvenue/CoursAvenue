/* Collection
 * ----------
 *
 * This module encapsulates construction of the basic Marionette CollectionView.
 *
 * **data API**
 *
 *  - _view_: Collection
 *  - _of_: a capitalized name of some resource, in the plural, like "Teachers" or
 *    "Courses".
 *  - _bootstrap_: The data to populate the collection on page load.
 *  - _template_: a template to be used in place of the default. The template must
 *    live in a folder named like views/widgets/templates/
 *
 *  In addition to the above options, you can provide "sample" markup that will
 *  be used by the Collection to decide its tagName/className, and by the ItemView
 *  if a vanilla itemview is used.
 *
 * **usage**
 *
 * Without sample markup.
 *
 *```
 *#structure-tabs{ data: { view: "Collection", of: "Teachers", bootstrap: @model.to_json }
 *```
 *
 * With sample markup for CollectionView and ItemView.
 *
 *```
 *#structure-tabs{ data: { view: "Collection", of: "Teachers", bootstrap: @model.to_json }
 *  %ul.some-classes
 *    %li.another-class
 *```
 */
Daedalus.module('Views.Collection', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Collection = Marionette.CollectionView.extend({

        /* ***
         * ** override **
         *
         * The Collection Module overrides renderItemView to allow a collection
         * to easily be applied to HTML that already exists on the page. The idea
         * is that, if an elements with `[data-view=collection]` has children, each
         * of those children will be used as itemviews in the order that they appear
         * on the page.
         *
         * We are depending on the order of the collection matching the order that
         * the elements were rendered on the server-side. This could become problematic
         * so we should watch out for situations where the data in the itemview's model
         * does not match the data rendered in the element.
         *
         * We should additionally watch out for a case when there are fewer elements
         * rendered on the page than items in the collection, since I'm not too sure
         * what would happen there ^o^//
         */
        renderItemView: function(view, index) {
            var existing_el = this.options.$children.get(index);
            if (view.attach === undefined || existing_el === undefined) {
                view.render();
            } else {
                view.attach(this.options.$children.get(index).innerHTML)
            }

            this.appendHtml(this, view, index);
        }
    });

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-view=Collection]").each(function (index, element) {
            var $element     = $(element),
                view         = $element.data("view"), // the name of the constructor
                bootstrap    = $element.data("bootstrap"), // data for the collection
                flavor       = $element.data("flavor"), // a sub class
                resource     = $element.data("of"), // used for template name, model name, etc...
                sample_tag   = $element.find("[data-sample-tag]")[0],
                sample_item  = $element.find("[data-sample-item]")[0],
                template     = $element.data("template")? Module.templateDirname() + $element.data("template") : undefined,
                view, region_name, regions ={},
                $children    = $element.children().children();

            view = buildView(view, flavor, {
                template:      template,
                bootstrap:     bootstrap,
                resource:      resource,
                tag:           sample_tag,
                itemview_tag:  sample_item,
                $children:      $children
            }),

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
        if (options.bootstrap && options.bootstrap.length > 0) {
            options.bootstrap[0].is_first = (options.bootstrap[0].is_first === undefined)? true : options.bootstrap[0].is_first;
        }

        var result,
            // Widgets might have a model/widgets collection or a views/widgets/widget itemview
            resources      = options.resource.toLowerCase(),
            resource       = _.singularize(resources),
            template_name  = (options.template)? options.template : resource,
            Collection, ItemView, collection,
            itemview_options = {};

        // build up the tagNames and classNames from the sample
        if (options.tag) {
            options.tagName   = options.tag.nodeName.toLowerCase();
            options.className = options.tag.className;
        }

        if (options.itemview_tag) {
            itemview_options.tagName   = options.itemview_tag.nodeName.toLowerCase();
            itemview_options.className = options.itemview_tag.className;
        }

        Collection = App.Models[resources] || Backbone.Collection.extend();
        collection = new Collection(options.bootstrap || {});

        // if there is a custom itemView, use that
        if (App.Views[_.capitalize(resources)] && App.Views[_.capitalize(resources)][_.capitalize(resource)]) {
            ItemView = App.Views[_.capitalize(resources)][_.capitalize(resource)];
        } else {
            ItemView = Marionette.ItemView;
        }

        // if we are using a generic item view, extend it to use the template
        itemview_options.template = 'backbone/structure_profile/views/' + resources + '/templates/' + template_name;
        ItemView                  = ItemView.extend(itemview_options);

        options.collection = collection;
        options.itemView   = ItemView;

        return new Module.Collection(options);
    };

}, undefined);


