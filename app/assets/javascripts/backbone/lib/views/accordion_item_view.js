CoursAvenue.module('Lib.Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.AccordionItemView = Module.EventLayout.extend({

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
            this.$el.find('[data-behavior=accordion-data]').slideUp();
        },

        maximize: function() {
            this.$el.find('[data-behavior=accordion-data]').slideDown('slow');
        }
    });
});
