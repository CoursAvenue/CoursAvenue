
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters.FilterBreadcrumbs', function(Module, App, Backbone, Marionette, $, _) {

    Module.FilterBreadcrumbsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'filter_breadcrumbs_view',

        initialize: function() {
            this.breadcrumbs = {};
        },

        ui: {
            '$breadcrumbs': '[data-trigger=clear]'
        },

        events: {
            'click @ui.$breadcrumbs': 'clear'
        },

        // @data: - hash
        //    target: name of the filter
        //    name
        removeBreadCrumb: function(data) {
            delete this.breadcrumbs[data.target];
            this.render();
        },

        // @data: - hash
        //    target
        //    name
        addBreadCrumb: function(data) {
            this.breadcrumbs[data.target] = {target: data.target};
            switch(data.target) {
                case 'level':
                    this.breadcrumbs[data.target].name = 'Niveaux';
                break;
                case 'audience':
                    this.breadcrumbs[data.target].name = 'Public';
                break;
                case 'subject_slug':
                    this.breadcrumbs[data.target].name = 'Discipline';
                break;
                case 'course_type':
                    this.breadcrumbs[data.target].name = 'Type de cours';
                break;
                case 'discount':
                    this.breadcrumbs[data.target].name = 'Tarifs réduits';
                break;
                case 'date':
                    this.breadcrumbs[data.target].name = 'Date';
                break;
                case 'price':
                    this.breadcrumbs[data.target].name = 'Prix';
                break;
                case 'structure_type':
                    this.breadcrumbs[data.target].name = 'Type de structure';
                break;
                case 'payment_method':
                    this.breadcrumbs[data.target].name = 'Financements acceptés';
                break;
                case 'search_term':
                    this.breadcrumbs[data.target].name = 'Mots clés';
                break;
                case 'location':
                    this.breadcrumbs[data.target].name = 'Lieux';
                break;
            }
            this.render();
        },

        // TODO debounce the removal of filters, so that if a person clear
        // many filters we will only emit one event.
        // TODO OR namespace the events for each filter
        // for now, will namespace, but I can see that being weird
        clear: function (e) {
            var data = $(e.currentTarget).data();
            this.trigger('breadcrumbs:clear:' + data.target);
            this.$el.find(e.currentTarget).remove();
        },

        serializeData: function() {
            return {
                breadcrumbs: this.breadcrumbs
            }
        }
    });
});
