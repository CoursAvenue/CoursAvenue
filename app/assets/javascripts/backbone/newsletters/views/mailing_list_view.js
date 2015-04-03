Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_view',
        tagName: 'div',
        className: 'input',

        events: {
            'change [type=radio]':         'selectMailingList',
        },

        initialize: function initialize () {
            _.bindAll(this, 'selectMailingList');

            Handlebars.registerHelper('isSelected', function(inputValue, predicate) {
                return inputValue == predicate ? 'selected' : '';
            });

            if (this.model.has('selected') && this.model.get('selected') == true) {
                this.trigger('selected', { model: this.model });
            }

            this.model.set('allTags', window.coursavenue.bootstrap.models.tags);
        },

        selectMailingList: function selectMailingList () {
            this.model.set('selected', true);

            this.trigger('selected', { model: this.model });
        },
    });
});

