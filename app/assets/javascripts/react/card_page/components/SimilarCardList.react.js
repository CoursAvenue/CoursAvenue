var _                    = require('lodash'),
    cx                   = require('classnames/dedupe'),
    Card                 = require('../../search_page_app/components/CourseCard'),
    CourseActionCreators = require('../actions/CourseActionCreators'),
    SimilarCardStore     = require('../stores/SimilarCardStore');

var SlidingPage = React.createClass({
    render: function render () {
        if (!this.props.cards) { return false; }
        var width_class = 'grid__item v-middle one-quarter palm-one-whole';
        var cards = this.props.cards.map(function (card, index) {
            return (
                <Card card={ card }
               width_class={ width_class }
              follow_links={ true }
                       key={ index } />
            );
        });

        var classes = cx('grid center-block relative', this.props.classes);

        return (
            <div className={ classes }>
                <a className='link-not-outlined grid_item v-middle muted-link one-eighth visuallyhidden--palm inline-block text--center' onClick={ this.props.prevPage } href='javascript:void(0)'>
                    <i className={ cx('fa fa-3x gray-light fa-chevron-left', { visuallyhidden: this.props.current_page == 0 }) }></i>
                </a>
                { cards }
                <a className='link-not-outlined grid_item v-middle muted-link one-eighth visuallyhidden--palm inline-block text--center' onClick={ this.props.nextPage } href='javascript:void(0)'>
                    <i className={ cx('fa fa-3x gray-light fa-chevron-right', { visuallyhidden: (this.props.current_page + 1) == this.props.total_pages }) }></i>
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

    nextPage: function nextPage (total_pages) {
        return function () {
            if ((this.state.current_page + 1) < total_pages) {
                this.setState({ current_page: this.state.current_page + 1 });
            }
        }.bind(this);
    },

    prevPage: function prevPage (total_pages) {
        return function () {
            if ((this.state.current_page - 1) >= 0) {
                this.setState({ current_page: this.state.current_page - 1 });
            }
        }.bind(this);
    },

    render: function render () {
        if (SimilarCardStore.isEmpty()) { return false; }
        var total_pages = Math.ceil(SimilarCardStore.length / this.props.per_page);

        var pages = _.chunk(SimilarCardStore.models, this.props.per_page).map(function (cards, index) {

            var page_class = cx('search-page-filter__subject-page absolute north west one-whole', {
                'search-page-filter__subject-page-before':  index >  this.state.current_page,
                'search-page-filter__subject-page--active': index == this.state.current_page,
                'search-page-filter__subject-page-after':   index <  this.state.current_page,
            });

            return (
                <SlidingPage cards={ cards }
                           classes={ page_class }
                      current_page={ index }
                       total_pages={ total_pages }
                          prevPage={ this.prevPage(total_pages) }
                          nextPage={ this.nextPage(total_pages) }
                               key={ index } />
            );
        }.bind(this));

        var style = { height: '500px' };
        return (
            <div className='relative overflow-hidden' style={ style }>
                { pages }
            </div>
        );
    },
});

module.exports = SimiliarCardList;
