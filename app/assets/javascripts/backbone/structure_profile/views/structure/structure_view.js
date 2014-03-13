
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

        initialize: function initialize () {
            _.bindAll(this, "showOrCreateTab");

            // eaves drop on bootstraps tab implementation
            $(document).on("click", '[data-toggle=tab]', this.showOrCreateTab);
        },

        onAfterShow: function onAfterShow () {
            this.trigger("filter:breadcrumbs:add", this.model.get("query_params"));
        },

        onRender: function onRender () {
            var $currently_active_tab = $(".tabs li.active"),
                anchor = $currently_active_tab.find("[data-toggle]");

            if (anchor.length > 0) {
                anchor = anchor[0];
                this.showOrCreateTab({ currentTarget: anchor });
            } else {
                this.showOrCreateTab({ currentTarget: $("[data-view=courses]")[0] });
            }
        },

        refetchCourses: function refetchCourses (data) {
            var params = this.model.get("query_params");

            if (data === undefined) {
                params = {};
            } else {
                _.each(data, function (value, key) {
                    if (_.has(params, value)) {
                        delete params[value];
                    }
                });
            }

            this.model.set("query_params", params);
            this.model.fetchRelated("courses", { data: this.getParamsForResource("courses")}, true)[0].then(function (models) {

            }.bind(this));
        },

        showOrCreateTab: function showOrCreateTab (e) {
            var $target   = $(e.currentTarget),
                resources = $target.data("view"),
                ViewClass, view, model;

            // if this tab has no associated resource, or if it is already populated, we bail
            if (!resources || $($target.attr("href")).children().length > 0) {
                return;
            }

            ViewClass = this.findOrCreateCollectionViewForResource(resources);

            // view = new ViewClass({
            //     collection: this.model.get(resources),
            //     data_url: this.model.get("data_url")
            // });

            // this.showWidget(view);

            // this.model.fetchRelated(resources, { data: this.getParamsForResource(resources)}, true);

            // Only fetch when there is no data
            view = new ViewClass({
                collection: this.model.get(resources),
                data_url: this.model.get("data_url")
            });
            this.showWidget(view);
            this.model.get(resources).fetch();
            if (!this.model.get(resources) || this.model.get(resources).length == 0) {
                this.model.fetchRelated(resources, { data: this.getParamsForResource(resources)}, true)[0].then(function (collection) {
                    view = new ViewClass({
                        collection: new Backbone.Collection(collection),
                        data_url: this.model.get("data_url")
                    });
                }.bind(this));
            }
        },

        getParamsForResource: function getParamsForResource (resource) {
            return _.extend({}, this.params_for_resource[resource], this.model.get("query_params"));
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
                    }),
                    // TODO this seems like it shouldn't be necessary...
                    // I thought this would just happen automatically?
                    collectionEvents: {
                        'change': 'render'
                    }
                });
            }

            return ViewClass;
        }
    });
});
