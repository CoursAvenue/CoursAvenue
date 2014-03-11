
/* just a basic marionette view */
StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.EventLayout.extend({
        className: 'tabs-container',
        template: Module.templateDirname() + 'structure_view',

        params_for_resource: {
            courses: {},
            teachers: {},
            comments: {
                unlimited_comments: true
            }
        },

        initialize: function () {
            _.bindAll(this, "showOrCreateTab");

            // eaves drop on bootstraps tab implementation
            $(document).on("click", '[data-toggle=tab]', this.showOrCreateTab);
        },

        onRender: function () {
            var $currently_active_tab = $(".tabs li.active"),
                anchor = $currently_active_tab.find("[data-toggle]");

            if (anchor.length > 0) {
                anchor = anchor[0];
                this.showOrCreateTab({ currentTarget: anchor });
            } else {
                this.showOrCreateTab({ currentTarget: $("[data-view=courses]")[0] });
            }
        },

        showOrCreateTab: function (e) {
            var $target   = $(e.currentTarget),
                resources = $target.data("view"),
                ViewClass, view, model;

            // TODO we can't do it this way, since the tab will always be
            // prepopulated the first time we fetch
            // if the tab is already populated, don't populate it
          //if ($($target.attr("href")).children().length > 0) {
          //    return;
          //}

            ViewClass = this.findOrCreateCollectionViewForResource(resources);

            this.model.fetchRelated(resources, { data: this.getParamsForResource(resources)}, true)[0].then(function (collection) {
                view = new ViewClass({
                    collection: new Backbone.Collection(collection),
                    data_url: this.model.get("data_url")
                });

                this.showWidget(view);
            }.bind(this));
        },

        getParamsForResource: function getParamsForResource (resource) {
            return _.extend(this.params_for_resource[resource], this.model.get("query_params"));
        },

        findOrCreateCollectionViewForResource: function findOrCreateCollectionViewForResource (resources) {
            var resource = _.singularize(resources),
                ViewClass;

            if (Module[_.capitalize(resources)] && Module[_.capitalize(resources)][_.capitalize(resources) + 'CollectionView']) {
                ViewClass = Module[_.capitalize(resources)][_.capitalize(resources) + 'CollectionView'];

            } else {
                ViewClass = Backbone.Marionette.CollectionView.extend({
                    template: Module.templateDirname() + resources + '/' + resources + '_collection_view',
                    className: 'white-box islet',
                    itemView: Marionette.ItemView.extend({
                        template: Module.templateDirname() + resources + '/' + resource + '_view'
                    })
                });
            }

            return ViewClass;
        }
    });
});
