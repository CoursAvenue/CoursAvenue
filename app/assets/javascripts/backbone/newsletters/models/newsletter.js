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

            var layout = layouts.get(this.get('layout_id'))
            this.set('layout', layout);

            this.setBlocs();
        },

        setBlocs: function setBlocs () {
            if (this.has('blocs') && (! _.isEmpty(this.get('blocs')))) { return ; }
            var blocs = [];

            this.get('layout').get('blocs').forEach(function(blocType, index) {
                var bloc = { type: blocType, position: index + 1, index: index };
                blocs.push(bloc);
            }, this);

            this.set('blocs', blocs);
        },

        // For some reason, when updating, some attributes are not namespace'd into `newsletter`,
        // and are therefore not found by Rails strong parameters. This fixes that by manually
        // generating the JSON sent to the server.
        toJSON: function () {
            return { newsletter: _.clone(this.attributes) }
        },
    });
});
