FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.AccordionItemView = Backbone.Marionette.Layout.extend({

        accordionClose: function() {
            this.minimize();
            this.model.set({ selected: false });
        },

        accordionOpen: function() {
            console.log("AccordionItemView->accordionOpen");

            if (this.model.get("selected") === true) {
                return false;
            }

            this.model.set({ selected: true });
            this.maximize();
            this.trigger("accordion:open", this.model.cid);

            return true;
        },

        /* hide for now, since slideUp is being mean */
        minimize: function() {
            this.$el.find('[data-type=accordion-data]').hide();
        },

        maximize: function() {
            this.$el.find('[data-type=accordion-data]').show();
        }
    });
});
