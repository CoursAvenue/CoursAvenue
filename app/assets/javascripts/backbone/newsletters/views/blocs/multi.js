Newsletter.module('Views.Blocs', function(Module, App, Backbone, Marionette, $, _) {
    Module.Multi = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'multi',
        tagName: 'div',
        childViewContainer: '[data-type=sub-blocs]',

        initialize: function initialize () {
            var layout        = this.model.collection.newsletter.get('layout')
            var subBlocsTypes = layout.get('sub_blocs')[this.model.get('index')];
            var subBlocs      = []

            subBlocs = subBlocsTypes.map(function(blocType, index) {
                return { type: blocType, index: index, position: index + 1, isSubBloc: true };
            });

            this.collection = new Newsletter.Models.BlocsCollection(subBlocs, {
                multiBloc:  this.model,
                newsletter: this.model.collection.newsletter,
            });
        },

        getChildView: function getChildView (item) {
            var viewType = item.get('view_type')

            if (viewType == 'multi') {
                throw "A multi bloc can't have a multi bloc parent.";
            } else if (viewType == 'image') {
                return Module.Image;
            } else {
                return Module.Text;
            }
        },
    });
});
