
StructureProfile.module('Views.Structure.Places', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlacesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.PlaceView,
        template: Module.templateDirname() + 'places_collection_view',
        itemViewContainer: '[data-type=container]',

        ui: {
            '$list': '[data-type=container]'
        },

        events: {
            'click [data-action=show-all-places]' : 'showAllPlace'
        },

        onItemviewMouseenter: function onItemviewMouseenter (view, data) {
            this.trigger("place:mouse:enter", data);
        },

        onItemviewMouseleave: function onItemviewMouseleave (view, data) {
            this.trigger("place:mouse:leave", data);
        },

        showAllPlace: function() {
            // debugger
            this.ui.$list.slideToggle();
            // var places_are_hidden   = true;
            // $('#show-all-places').click(function() {
            //     $('#place-list').slideToggle();
            //     if (places_are_hidden) {
            //         $(this).text('Cacher les adresses');
            //     } else {
            //         $(this).text('Voir les adresses');
            //     }
            //     places_are_hidden = !places_are_hidden;
            // });

        }

    });
});
