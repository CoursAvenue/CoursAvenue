FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.AccordionItemView = Backbone.Marionette.Layout.extend({

        accordionClose: function() {
            this.model.set({ selected: false });
            this.minimize();
            this.trigger("accordion:close", this.model.cid);
        },

        accordionOpen: function() {
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
            this.$el.find('[data-type=accordion-data]').slideUp();
        },

        maximize: function() {
            this.$el.find('[data-type=accordion-data]').slideDown('slow');
        }
    });
});
