Newsletter.module('Views.Blocs', function(Module, App, Backbone, Marionette, $, _) {
    Module.Multi = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'multi',
        tagName: 'div',
        childViewContainer: '[data-type=sub-blocs]',
        className: function className () {
            if (this.model.collection.newsletter.get('layout').get('disposition') == 'vertical') {
                return 'one-half inline-block soft-half--sides';
            }
            return ''
        },

        initialize: function initialize () {
            var newsletter    = this.model.collection.newsletter;
            var layout        = newsletter.get('layout')
            var subBlocsTypes = layout.get('sub_blocs')[this.model.get('position') - 1];
            var subBlocs      = this.model.get('sub_blocs');

            if (_.isEmpty(subBlocs)) {
                subBlocs = subBlocsTypes.map(function(blocType, index) {
                    return { type: blocType, index: index, position: index + 1 };
                });
            }

            this.collection = new Newsletter.Models.BlocsCollection(subBlocs, {
                multiBloc:  this.model,
                newsletter: newsletter,
            });

            this.model.set('newsletter', newsletter);
            this.model.save();
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
