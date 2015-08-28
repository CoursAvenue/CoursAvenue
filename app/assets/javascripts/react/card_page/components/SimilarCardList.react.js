var _                    = require('lodash'),
    cx                   = require('classnames/dedupe'),
    Card                 = require('../../search_page_app/components/CourseCard'),
    CourseActionCreators = require('../actions/CourseActionCreators'),
    SimilarCardStore     = require('../stores/SimilarCardStore');

var SlidingPage = React.createClass({
    render: function render () {
        if (!this.props.cards) { return false; }
        var width_class = 'grid__item one-quarter';
        var cards = this.props.cards.map(function (card, index) {
            return (
                <Card card={ card }
               width_class={ width_class }
              follow_links={ true }
                       key={ index } />
            );
        });

        var classes = cx('grid text--center', {
            'hidden': !this.props.visible
        });

        return (
            <div className={ classes }>
                { cards }
            </div>
        );
    },
});

var SimiliarCardList = React.createClass({

    mixins: [
        FluxBoneMixin(['card_store'])
    ],

    componentWillMount: function componentWillMount () {
        CourseActionCreators.bootstrapSimilarProfiles(this.props.card);
    },

    getInitialState: function getInitialState () {
        return { card_store: SimilarCardStore };
    },

    render: function render () {
        if (SimilarCardStore.isEmpty()) { return false; }
        var pages = _.chunk(SimilarCardStore.models, 3).map(function (cards, index) {
            return (
                <SlidingPage cards={ cards } visible={ index == 0 } key={ index } />
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
