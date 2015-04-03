Newsletter.module('Views.Blocs', function(Module, App, Backbone, Marionette, $, _) {
    Module.Text = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'text',
        tagName: 'div',
        className: function className () {
            var classes     = '';
            var layout      = this.model.collection.newsletter.get('layout');
            var disposition = layout.get('disposition');
            var subBlocs    = layout.get('sub_blocs')[this.model.get('position') - 1];
            var proportions = layout.get('proportions')[this.model.get('position') - 1]


            if (this.model.collection.multiBloc && disposition == 'horizontal') {
                var classIndex = subBlocs.indexOf(this.model.get('view_type'));
                classes += 'inline-block soft-half--sides v-top ' + proportions[classIndex];
            } else {
                classes += 'push-half--bottom'
            }

            return classes;
        },

        events: {
            'change input':    'silentSave',
            'change textarea': 'silentSave'
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();

            var positionLabel = this.model.collection.where({ type: this.model.get('type') }).indexOf(this.model) + 1
            if (this.model.collection.multiBloc) {
                positionLabel = this.model.collection.multiBloc.get('position') + '-' + positionLabel;
            }
            this.model.set('position_label', positionLabel);

            _.bindAll(this, 'onShow', 'silentSave');
        },

        // Custom render function.
        // We start by calling the Marionette CompositeView's render function on this view.
        // We then bind the model to the inputs by calling modelBinder.
        render: function render () {
            Backbone.Marionette.ItemView.prototype.render.apply(this, arguments);

            this._modelBinder.bind(this.model, this.el);
        },

        onShow: function onShow () {
            var text_areas = this.$el.find('[data-type=redactor]');
            var model      = this.model;

            text_areas.each(function(index, elem) {
                $(elem).redactor({
                      buttons: ['formatting', 'bold', 'italic','unorderedlist', 'orderedlist',
                                'link', 'alignment', 'horizontalrule', 'underline'],
                      lang: 'fr',
                      formatting: ['p', 'blockquote', 'h1', 'h2', 'h3'],
                      blurCallback: function blurCallback (event) {
                          this.$element.trigger('change', event);
                      },
                      initCallback: function initCallback () {
                          if (model.has('content')) {
                              this.code.set(model.get('content'));
                          }
                      },
                });
            });
        },

        silentSave: function silentSave () {
            this.model.save();
        }.debounce(500),

    })
});
