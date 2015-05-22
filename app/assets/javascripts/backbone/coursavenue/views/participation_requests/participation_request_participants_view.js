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
        },

        computePrices: function computePrices (options) {
            var grand_total = 0,
                total_nb_participants = 0;
            this.ui.$price_rows.filter(':not([data-hidden])').each(function() {
                if ($(this).find('[data-element=price-select]').find(':selected').length == 0) { return; }
                var price             = parseFloat($(this).find('[data-element=price-select]').find(':selected').data('amount'), 10);
                nb_participants       = parseInt($(this).find('[data-element=number-select]').val() || 0, 10);
                total_nb_participants = total_nb_participants + nb_participants;
                var total             = price * nb_participants;
                grand_total           = grand_total + total;
                if (nb_participants > 1 && price != 0) {
                    $(this).find('[data-element=row-total]').text(nb_participants + ' x ' + COURSAVENUE.helperMethods.readableAmount(price));
                } else {
                    $(this).find('[data-element=row-total]').text(COURSAVENUE.helperMethods.readableAmount(total));
                }
            });
            if (total_nb_participants > 1) {
                this.ui.$grand_total_wrapper.removeClass('hidden');
            } else {
                this.ui.$grand_total_wrapper.addClass('hidden');
            }
            if (this.ui.$price_rows.length > 0) {
                this.ui.$grand_total.text(COURSAVENUE.helperMethods.readableAmount(grand_total));
                this.trigger('participation_request:total', {
                    total:       COURSAVENUE.helperMethods.readableAmount(grand_total),
                    total_price: grand_total
                });
            }
        },

        serializeData: function serializeData () {
            return {
                has_more_than_one_price: (this.prices_collection.length > 1),
                prices: this.prices_collection.toJSON()
            };
        }
    });
});
