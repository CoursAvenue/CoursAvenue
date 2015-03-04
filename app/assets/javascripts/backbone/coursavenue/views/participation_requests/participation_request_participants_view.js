CoursAvenue.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _) {
    Module.ParticipationRequestParticipantsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'participation_request_participants_view',

        events: {
            'change select'       : 'computePrices',
            'click [data-clear]'  : 'computePrices',
            'click [data-trigger]': 'computePrices'
        },

        ui: {
            '$grand_total'        : '[data-behavior=total]',
            '$price_rows'         : '[data-price-row]',
            '$grand_total_wrapper': '[data-element=grand-total-wrapper]'
        },

        initialize: function initialize () {
            this.prices_collection = new CoursAvenue.Models.PricesCollection();
        },

        hidePricesCollection: function hidePricesCollection () {
            this.$el.slideUp();
        },

        resetPricesCollection: function resetPricesCollection (course) {
            this.$el.slideDown();
            this.prices_collection.reset(course.prices);
            this.render();
        },

        onRender: function onRender (options) {
            this.computePrices();
            this.$('[data-behavior=show-more-on-demand]').showMoreOnDemand();
        },

        computePrices: function computePrices (options) {
            var grand_total = 0;
            if (this.ui.$price_rows.filter(':not([data-hidden])').length > 1) {
                this.ui.$grand_total_wrapper.removeClass('hidden');
            } else {
                this.ui.$grand_total_wrapper.addClass('hidden');
            }
            this.ui.$price_rows.filter(':not([data-hidden])').each(function() {
                var price  = parseFloat($(this).find('[data-element=price-select]').find(':selected').data('amount'), 10);
                var number = parseInt($(this).find('[data-element=number-select]').val() || 0, 10);
                var total  = price * number;
                grand_total  = grand_total + total;
                $(this).find('[data-element=row-total]').text(COURSAVENUE.helperMethods.readableAmount(total))
            });
            if (this.ui.$price_rows.length > 0) {
                this.ui.$grand_total.text(COURSAVENUE.helperMethods.readableAmount(grand_total));
                this.trigger('participation_request:total', { total: COURSAVENUE.helperMethods.readableAmount(grand_total) });
            }
        },

        serializeData: function serializeData () {
            return {
                prices: this.prices_collection.toJSON()
            };
        }
    });
});
