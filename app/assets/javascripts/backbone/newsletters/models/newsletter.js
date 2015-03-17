Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Newsletter = Backbone.Model.extend({

        initialize: function initialize () {
            this.setLayout();
            this.bind('change:layout_id', this.setLayout);
        },

        urlRoot: function urlRoot () {
            return Routes.pro_structure_newsletters_path(window.coursavenue.bootstrap.structure);
        },

        setLayout: function setLayout (layouts) {
            var layouts = new Module.LayoutsCollection(window.coursavenue.bootstrap.models.layouts);
            if (!this.get('layout_id')) {
                var layout_id = window.coursavenue.bootstrap.layout;
                this.set('layout_id', layout_id);
            }

            var layout = layouts.at(this.get('layout_id'))
            this.set('layout', layout);

            this.setBlocs();
        },

        setBlocs: function setBlocs () {
            var blocs = [];

            this.get('layout').get('blocs').forEach(function(blocType, index) {
                var bloc = { type: blocType, position: index + 1, index: index };
                blocs.push(bloc);
            }, this);

            this.set('blocs', blocs);
        },

    });
});
