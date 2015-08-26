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

        ui: {
            '$textarea' : '[data-type=redactor]'
        },
        events: {
            'update:content textarea' : 'updateContent',
            'keyup input'             : 'silentSave',
            'keyup textarea'          : 'silentSave',
            'change input'            : 'silentSave',
            'change textarea'         : 'silentSave'
        },

        updateContent: function updateContent () {
            this.model.set('content', this.ui.$textarea.val());
            this.silentSave();
        },
        initialize: function initialize () {
            var positionLabel = this.model.collection.where({ type: this.model.get('type') }).indexOf(this.model) + 1
            if (this.model.collection.multiBloc) {
                positionLabel = this.model.collection.multiBloc.get('position');
            }
            this.model.set('position_label', positionLabel);
            if (!this.model.has('newsletter')) {
                this.model.set('newsletter', this.model.collection.newsletter);
            }

            _.bindAll(this, 'onShow', 'silentSave');
        },

        // Custom render function.
        // We start by calling the Marionette CompositeView's render function on this view.
        // We then bind the model to the inputs by calling modelBinder.
        render: function render () {
            Backbone.Marionette.ItemView.prototype.render.apply(this, arguments);
        },

        onShow: function onShow () {
            var model = this.model;
            // var $textarea = this.$el.find('[data-type=redactor]')
            this.ui.$textarea.redactor({
                  buttons: ['formatting', 'bold', 'italic','unorderedlist', 'orderedlist',
                            'link', 'alignment', 'horizontalrule', 'underline'],
                  lang: 'fr',
                  formatting: ['p', 'blockquote', 'h1', 'h2', 'h3'],
                  blurCallback: function blurCallback (event) {
                      model.set('content', this.ui.$textarea.val());
                      this.ui.$textarea.trigger('change', event);
                  }.bind(this),
                  initCallback: function initCallback () {
                      if (model.has('content') && ! _.isEmpty(model.get('content'))) {
                          this.code.set(model.get('content'));
                      } else {
                          var structure      = window.coursavenue.bootstrap.models.structure;
                          var defaultContent = Module.templateDirname() + 'text_content';
                          var content = JST[defaultContent](structure);

                          this.code.set(content);
                          // Save in DB to be able to preview the email
                          model.set('content', content);
                          // Prevent from bug, dunnow why...
                          setTimeout(function() {
                              model.save();
                          }, 500);
                      }
                  },
            });
        },

        silentSave: function silentSave () {
            this.model.save();
        }.debounce(500),

    })
});
