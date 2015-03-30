
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Price = Backbone.Model.extend({
        toJSON: function toJSON () {
            return _.extend(this.attributes, {
                has_promotion        : this.has_promotion(),
                readable_amount      : this.readable_amount(),
                readable_promo_amount: this.readable_promo_amount()
            });
        },
        has_promotion: function readable_amount () {
            return (this.get('promo_amount') && this.get('amount'));
        },

        readable_promo_amount: function readable_promo_amount () {
            return COURSAVENUE.helperMethods.readableAmount(this.get('promo_amount'), this.get('promo_amount_type'));
        },
        readable_amount: function readable_amount () {
            return COURSAVENUE.helperMethods.readableAmount(this.get('amount'), '€');
        }
    });
});
