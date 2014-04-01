
StructureProfile.module('Views.Structure.Places', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlacesCollectionView = Marionette.CompositeView.extend({
        itemView: Module.PlaceView,
        template: Module.templateDirname() + 'places_collection_view',
        itemViewContainer: '[data-type=item-view-container]',

        ui: {
            '$list': '[data-type=container]'
        },

        events: {
            'click [data-action=show-places]'     : 'showPlaces',
            'click [data-action=show-all-places]' : 'refetchPlaces'
        },

        onItemviewMouseenter: function onItemviewMouseenter (view, data) {
            this.trigger("place:mouse:enter", data);
        },

        onItemviewMouseleave: function onItemviewMouseleave (view, data) {
            this.trigger("place:mouse:leave", data);
        },

        showPlaces: function showPlaces() {
            this.ui.$list.slideToggle();
        },

        refetchPlaces: function refetchPlaces() {
            this.collection.fetch();
        },

        serializeData: function serializeData() {
            this.other_places_nb = this.collection.structure.get('places_count') - this.collection.length;
            return {
                has_more_places: this.other_places_nb > 0,
                other_places_nb: this.other_places_nb
            }
        }

    });
});
