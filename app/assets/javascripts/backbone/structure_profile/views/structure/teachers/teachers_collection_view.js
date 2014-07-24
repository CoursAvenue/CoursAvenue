StructureProfile.module('Views.Structure.Teachers', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TeacherView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'teacher_view',
        className: 'one-half inline-block push--bottom'
    });

    Module.TeachersCollectionView = Backbone.Marionette.CollectionView.extend({
        template: Module.templateDirname() + 'teachers_collection_view',
        itemView: Module.TeacherView,
        itemViewContainer: '[data-type=container]',

        collectionEvents: {
            'reset': 'render'
        },

        onRender: function onRender () {
            if (this.collection.length == 0) {
                this.$('[data-empty-teachers]').show();
            } else {
                this.$('[data-empty-teachers]').hide();
            }
        }
    });

}, undefined);
