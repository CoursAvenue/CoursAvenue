
/* just a basic marionette view */
StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.EventLayout.extend({
        className: 'tabs-container',
        template: Module.templateDirname() + 'structure_view',

        initialize: function () {
            _.bindAll(this, "showOrCreateTab");

            // eaves drop on bootstraps tab implementation
            $(document).on("click", '[data-toggle=tab]', this.showOrCreateTab);
        },

        showOrCreateTab: function (e) {
            var $target   = $(e.target),
                resources = $target.data("view"),
                resource  = _.singularize(resources),
                ViewClass, view, model;

            // if the tab is already populated, don't populate it
            if ($($target.attr("href")).children().length > 0) {
                return;
            }

            ViewClass = Backbone.Marionette.CollectionView.extend({
                template: Module.templateDirname() + resources + '/' + resources + '_collection_view',
                className: 'white-box islet',
                itemView: Marionette.ItemView.extend({
                    template: Module.templateDirname() + resources + '/' + resource + '_view'
                })
            });

            view = new ViewClass({
                collection: this.model.get(resources)
            });

            this.showWidget(view);
        }
    });
});
