CoursAvenue.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _) {
    Module.ParticipationRequestParticipantsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'participation_request_participants_view',

        events: {
            'change select'       : 'computePrices',
            'click [data-clear]'  : 'computePrices',
        },

        ui: {
            '$grand_total'        : '[data-behavior=total]',
            '$price_select'       : '[data-element=price-select]',
            '$price_info'         : '[data-element=price-info]'
        },

        initialize: function initialize () {
            this.prices_collection = new CoursAvenue.Models.PricesCollection();
        },

        hidePricesCollection: function hidePricesCollection () {
            this.$el.slideUp();
        },

        resetPricesCollection: function resetPricesCollection (course) {
            this.$el.slideDown();
            // Reject registration prices
            var prices = _.union(course.prices, course.price_group_prices);
            var prices = _.reject(prices, function(price) {
                return _.isNull(price) || price.is_registration || price.promo_amount_type == '%';
            });
            this.prices_collection.reset(prices);
            this.render();
        },

        onRender: function onRender (options) {
            this.computePrices();
            this.$('[data-behavior=show-more-on-demand]').showMoreOnDemand();
            // If there's only one option, don't show the select.
            if (this.prices_collection.length == 1) {
                var price = this.prices_collection.first();
                this.ui.$price_info.text(price.get('readable_promo_amount') || price.get('readable_amount'));
                this.ui.$price_info.show();
                this.ui.$price_select.hide();
            }
        },

        computePrices: function computePrices (options) {
            var grand_total = 0;
            var price             = parseFloat(this.$('[data-element=price-select]').find(':selected').data('amount'), 10);
            nb_participants       = parseInt(this.$('[data-element=number-select]').val() || 0, 10);
            var total             = price * nb_participants;
            grand_total           = grand_total + total;
            this.$('[data-element=total]').text(COURSAVENUE.helperMethods.readableAmount(total));
            this.ui.$grand_total.text(COURSAVENUE.helperMethods.readableAmount(grand_total));
            this.trigger('participation_request:total', {
                total:       COURSAVENUE.helperMethods.readableAmount(grand_total),
                total_price: grand_total
            });
        },
        serializeData: function serializeData () {
            return {
                prices: this.prices_collection.toJSON()
            };
        }
    });
});
