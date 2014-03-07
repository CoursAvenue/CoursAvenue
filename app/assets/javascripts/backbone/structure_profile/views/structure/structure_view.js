
/* just a basic marionette view */
StructureProfile.module('Views.Structure', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructureView = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'structure_view',

        initialize: function () {
            _.bindAll(this, "showOrCreateTab");

            // eaves drop on bootstraps tab implementation
            $(document).on("click", '[data-toggle=tab]', this.showOrCreateTab);
        },

        showOrCreateTab: function () {
            var ViewClass, view, model;


            ViewClass = Backbone.Marionette.CompositeView.extend({
                template: Module.templateDirname() + "courses" + '/courses_collection_view',
                itemView: Marionette.ItemView.extend({
                    template: Module.templateDirname() + "courses" + '/course_view'
                }),
                itemViewContainer: '[data-type=container]'
            });

            // stuff for the composite part
            model = {
                name: "bob"
            };

            view = new ViewClass({
                collection: this.model.get("courses"),
                model: new Backbone.Model(model)
            });

            this.showWidget(view);
        }
    });
});
