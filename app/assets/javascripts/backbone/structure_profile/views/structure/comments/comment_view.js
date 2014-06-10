
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'comment_view',

        initialize: function initialize (options) {
            this.model.set('structure_name', options.structure_name);
        },

    });

}, undefined);
