StructureProfile.module('Views.Structure.Teachers', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TeacherView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'teacher_view',
        className: 'one-half inline-block',
        initialize: function initialize (options) {
            this.model.set('index', options.index);
        },
        onRender: function onRender () {
            if (this.model.get('index') > 1) {
                this.$el.addClass('structure-teachers-long hidden');
            }
        },
        onShow: function onShow () {
            if (this.model.get('index') == 2) {
                this.$el.before("<a href='#' data-behavior='show-long-version' data-long-version='.structure-teachers-long'>+ Voir tous les professeurs</a>");
            }
        }
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
            this.$('[data-behavior="lazy-load"]').lazyload();
        },
        itemViewOptions: function itemViewOptions (model, index) {
            return { index: index };
        }

    });

}, undefined);
