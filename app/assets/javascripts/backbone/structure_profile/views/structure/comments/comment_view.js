
StructureProfile.module('Views.Structure.Comments', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CommentView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'comment_view',

        initialize: function initialize (options) {
            this.model.set('structure_name', options.structure_name);
        },

        onRender: function onRender () {
            this.$('[data-behavior="lazy-load"]').lazyload();
        },

        serializeData: function serializeData () {
            var attributes = this.model.toJSON();
            if (attributes.reply) {
                attributes.reply.content = GLOBAL.hideContactsInfo(attributes.reply.content);
            }
            return attributes;
        }

    });

}, undefined);
