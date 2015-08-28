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
                <a className='grid_item one-eight' onClick={ this.props.prevPage } href='javascript:void(0)'>
                    <i className='fa fa-chevron-left'></i>
                </a>
                { cards }
                <a className='grid_item one-eight' onClick={ this.props.nextPage } href='javascript:void(0)'>
                    <i className='fa fa-chevron-right'></i>
                </a>
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

    getDefaultProps: function getDefaultProps () {
        return { per_page: 3 };
    },

    getInitialState: function getInitialState () {
        return { card_store: SimilarCardStore, current_page: 0 };
    },

    nextPage: function nextPage () {
        return function () {
            this.setState({ current_page: this.state.current_page + 1 });
        }.bind(this);
    },

    prevPage: function prevPage () {
        return function () {
            this.setState({ current_page: this.state.current_page - 1 });
        }.bind(this);
    },

    render: function render () {
        if (SimilarCardStore.isEmpty()) { return false; }
        var total_pages = Math.ceil(SimilarCardStore.length / this.props.per_page);

        var pages = _.chunk(SimilarCardStore.models, this.props.per_page).map(function (cards, index) {

            return (
                <SlidingPage cards={ cards }
                           visible={ index == this.state.current_page }
                          prevPage={ this.prevPage() }
                          nextPage={ this.nextPage() }
                               key={ index } />
            );
        }.bind(this));

        return (
            <div className='text--center'>
                { pages }
            </div>
        );
    },
});

module.exports = SimiliarCardList;
