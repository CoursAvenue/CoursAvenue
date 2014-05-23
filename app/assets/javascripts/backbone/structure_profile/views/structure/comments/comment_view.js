
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'comment_view',
    });

}, undefined);
