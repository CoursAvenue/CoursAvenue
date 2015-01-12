Emailing.module('Views.Sections.Bridges', function(Module, App, Backbone, Marionette, $, _) {
    Module.BridgeView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'bridge_view',

        tagName: 'div',

        events: {
            'click [data-slide-next]'     : 'slideNext',
            'click [data-slide-prev]'     : 'slidePrev',
            'click [data-subj-next]'      : 'subjectNext',
            'click [data-subj-prev]'      : 'subjectPrev',
            'keyup [data-subject-custom]' : 'subjectCustom',
            'click [data-review-next]'    : 'reviewNext',
            'click [data-review-prev]'    : 'reviewPrev',
            'keyup [data-review-custom]'  : 'reviewCustom',
            'keyup [data-city-custom]'    : 'cityCustom'
        },

        initialize: function initialize () {
            _.bindAll(this, 'setCurrentImage', 'setCurrentSubject', 'setCurrentReview', 'reviewCustom', 'collectionNext', 'showSavingIndicator');
            this.model.on('change', this.showSavingIndicator);
        },

        /* Change current to the next or previous element of collection.
         *
         * @param collectionName - The name of the collection in our model (ex. images, subjects)
         * @param collectionId   - The name of the id attribute of our collection in our model (ex. media_id, subject_id)
         * @param collectionSet  - The function setting the our new value. (ex. setCurrentImage, setCurrentSubject)
         * @param next           - Whether we are fetching the next one or the previous one.
         */
        collectionNext: function collectionNext (collectionName, collectionId, collectionSet, next) {
            var collection, current, index;
            collection = this.model.get(collectionName);
            current    = _.find(collection, function(collectionItem) {
                return (collectionItem.id == this.model.get(collectionId));
            }.bind(this));
            if (collection) {
                // Circle the indexes
                if (!next && collection.indexOf(current) == 0) {
                    index = collection.length - 1; // If going backward and is currently first, set to last
                } else if (next && collection.indexOf(current) == (collection.length - 1)) {
                    index = 0;// If going forward and is currently last, set to first
                } else {
                    index = (next ? (collection.indexOf(current) + 1) : (collection.indexOf(current) - 1));
                }
                collectionSet(collection[index]);
                this.render();
            }
        },

        slideNext: function slideNext () {
            this.collectionNext('images', 'media_id', this.setCurrentImage, true);
        },

        slidePrev: function slidePrev () {
            this.collectionNext('images', 'media_id', this.setCurrentImage, false);
        },

        subjectNext : function subjectNext () {
            this.collectionNext('subjects', 'subject_id', this.setCurrentSubject, true);
        },

        subjectPrev : function subjectPrev () {
            this.collectionNext('subjects', 'subject_id', this.setCurrentSubject, false);
        },

        subjectCustom : function subjectCustom () {
          var id         = this.model.get('id');
          var subject_id = this.model.get('subject_id');
          var text       = $('input[data-subject-custom=' + subject_id + '][data-bridge-id=' + id + ']').val();
          var subject    = { id: subject_id, name: text };

          this.setCurrentSubject(subject);
        }.debounce(500),

        reviewNext : function reviewNext () {
            this.collectionNext('reviews', 'review_id', this.setCurrentReview, true);
        },

        reviewPrev : function reviewPrev () {
            this.collectionNext('reviews', 'review_id', this.setCurrentReview, false);
        },

        reviewCustom : function reviewCustom () {
            var id = this.model.get('review_id');
            var text = $('input[data-review-custom=' + id + ']').val();
            var review = { id: this.model.get('review_id'), text: text, custom: true };

            this.setCurrentReview(review);
        }.debounce(500),

        setCurrentImage: function setCurrentImage (image) {
            if (image) {
                this.model.set( { media_url: image.url, media_id: image.id } );
            }
        },

        setCurrentSubject : function setCurrentSubject(subject) {
            if (subject) {
              this.model.set( { subject_name: subject.name, subject_id: subject.id } );
            }
        },

        setCurrentReview : function setCurrentReview(review) {
            if (review) {
              this.model.set( { review_text: review.text, review_id: review.id, review_custom: review.custom } );
            }
        },

        cityCustom: function cityCustom () {
            var id = this.model.get('id');
            var city = $('input[data-city-custom=' + id + ']').val();
            this.model.set('city_text', city);
        }.debounce(500),

        showSavingIndicator: function showSavingIndicator () {
            $('[data-el=saving-indicator]').fadeIn();
            setTimeout(function() {
                $('[data-el=saving-indicator]').fadeOut();
            }.bind(this), 1000);
        }

    });
});

