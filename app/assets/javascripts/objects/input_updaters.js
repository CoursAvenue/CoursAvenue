(function() {
    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.InputUpdater = new Class({

        initialize: function(el, options) {
            this.to_update = $(el.get('data-element'));
            this.el = el;
            this.type = this.el.get('type');

            if (this.type === 'submit') {
                this.el.addEvent('click', function(event) {
                    this.to_update.click();
                }.bind(this));
            } else {
                this.el.addEvent('change', function(event) {
                    switch (this.type) {
                        case 'checkbox':
                            this.to_update.set('checked', this.el.get('checked'));
                            break;
                        default:
                            this.to_update.set('value', this.el.get('value'));
                            break;
                    }
                }.bind(this));
            }
        }

    });
})();


// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=input-update]').each(function(el) {
        new GLOBAL.Objects.InputUpdater(el);
    });
});
