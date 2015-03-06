Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Newsletter = Backbone.Model.extend({

        initialize: function initialize () {
            this.setLayout();
            this.bind('change:layout_id', this.setLayout);
        },

        url: function url () {
            var structure = window.coursavenue.bootstrap.structure;
            return Routes.pro_structure_newsletter_path(structure, this.get('id'));
        },

        setLayout: function setLayout (layouts) {
            var layouts = new Module.LayoutsCollection(window.coursavenue.bootstrap.models.layouts);
            if (!this.get('layout_id')) {
                this.set('layout_id', 1);
            }

            var layout = layouts.get(this.get('layout_id'))
            this.set('layout', layout);

            this.setBlocs();
        },

        setBlocs: function setBlocs () {
            var blocs = [];

            this.get('layout').get('blocs').forEach(function(blocType, index) {
                var bloc = new Module.Bloc({ type: blocType, position: index + 1 });
                blocs.push(bloc);
            }, this);

            this.set('blocs', blocs);
        },

    });
});
