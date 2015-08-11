
/* just a basic marionette view */
StructurePlanning.module('Views.Map', function(Module, App, Backbone, Marionette, $, _) {

    Module.StickyGoogleMapsView = StructureProfile.Views.Map.StickyGoogleMapsView.extend({
        onShow: function onShow () {
            // If the current instance is the stycky map that appears on the right of the StructureProfile
            this.$('.google-map').addClass('google-map--medium-small');
            // Stick if it has to
            var setStickyStyle,
                $view             = this.$el.closest('[data-type=sticky-map-container]'),
                $grid_item        = $view.closest('.grid__item'),
                initial_map_width = $view.width();
            $view.sticky({
                updateOnScroll: true,
                z             : 10,
                oldWidth      : false,
                offsetTop     : 50,
                onStick: function onStick () {
                    $view.css({
                        left : $grid_item.offset().left + parseInt($view.closest('.grid__item').css('padding-left'), 10) + 'px',
                        width: initial_map_width
                    });
                },
                onUnStick: function onUnStick () {
                    $view.removeAttr('style');
                }
            });
        }

    });
});
