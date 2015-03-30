
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.Price = Backbone.Model.extend({
        toJSON: function toJSON () {
            return _.extend(this.attributes, {
                readable_amount: this.readable_amount()
            });
        },
        readable_amount: function readable_amount () {
            if (this.get('promo_amount') && this.get('amount')) {
                var string = COURSAVENUE.helperMethods.readableAmount(this.get('promo_amount'), this.get('promo_amount_type'));
                string += ' au lieu de ' + COURSAVENUE.helperMethods.readableAmount(this.get('amount'));
                return string;
            } else if (this.get('promo_amount')) {
                return COURSAVENUE.helperMethods.readableAmount(this.get('promo_amount'), this.get('promo_amount_type'));
            } else {
                return COURSAVENUE.helperMethods.readableAmount(this.get('amount'), this.get('promo_amount_type'));
            }
        }
    });
});
