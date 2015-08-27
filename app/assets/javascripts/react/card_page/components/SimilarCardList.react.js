var _                = require('lodash'),
    Card             = require('../../search_page_app/components/CourseCard'),
    CourseStore      = require('../stores/CourseStore'),
    SimilarCardStore = require('../stores/SimilarCardStore');

var SlidingPage = React.createClass({
    render: function render () {
        if (!this.props.cards) { return false; }
        var cards = this.props.cards.map(function (card, index) {
            return (
                <Card card={ card }
                       key={ index }
              follow_links={ true }
                       key={ index } />
            );
        });

        return (
            <div>
                { cards }
            </div>
        );
    },
});

var SimiliarCardList = React.createClass({

    mixins: [
        FluxBoneMixin(['card_store', 'course_store'])
    ],

    getInitialState: function getInitialState () {
        return { card_store: SimilarCardStore, course_store: CourseStore };
    },

    render: function render () {
        debugger
        var pages = _.chunk(SimilarCardStore.models, 4).map(function (cards, index) {
            return (
                <SlidingPage cards={ cards } key={ index } />
            );
        });

        return (
            <div className='text--center'>
                { pages }
            </div>
        );
    },
});

module.exports = SimiliarCardList;
