FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.AccordionItemView = Backbone.Marionette.CompositeView.extend({

        accordionClose: function() {
            this.minimize();
            this.model.set({ selected: false });
        },

        accordionOpen: function(e) {
            console.log("AccordionItemView->accordionOpen");
            e.preventDefault();

            if (this.model.get("selected") === true) {
                return false;
            }

            this.model.set({ selected: true });
            this.maximize();
            this.trigger("accordion:open", this.model.cid);

            return false;
        },

        /* hide for now, since slideUp is being mean */
        minimize: function() {
            this.$el.find('[data-type=accordion]').hide();
        },

        maximize: function() {
            this.$el.find('[data-type=accordion]').show();
        }
    });
});
