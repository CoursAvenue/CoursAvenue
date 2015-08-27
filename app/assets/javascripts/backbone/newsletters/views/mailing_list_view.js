Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'mailing_list_view',
        tagName: 'div',

        modelEvents: {
            'change:selected' : 'selectMailingList'
        },
        events: {
            'change [type=radio]': 'selectMailingList',
        },

        initialize: function initialize (options) {
            this.newsletter = options.newsletter;
            _.bindAll(this, 'selectMailingList');

            if (this.model.has('selected') && this.model.get('selected') == true) {
                this.trigger('selected', { model: this.model });
            }

            this.model.set('allTags', window.coursavenue.bootstrap.models.tags);
        },

        selectMailingList: function selectMailingList () {
            this.model.set('selected', true, { silent: true });
            this.render();
            this.trigger('selected');
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            return _.extend(data,
                            { edit_url: Routes.edit_pro_structure_newsletter_mailing_list_path(this.model.get('structure_id'), this.newsletter.get('id'), this.model.get('id') )});
        }
    });
});

