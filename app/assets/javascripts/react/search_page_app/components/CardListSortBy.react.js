var _                     = require('lodash'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    CardStore             = require("../stores/CardStore"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var SORT_BYS = [
    { name: 'Recommandations', key: 'by_popularity_desc'},
    { name: 'Les plus proches'          , key: 'proximity'}
];

var CardListSortBy = React.createClass({

    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState () {
        return {
            card_store: CardStore
        };
    },


    selectedContextTitle: function selectedContextTitle () {
        var card_store_sort_by = this.state.card_store.sort_by;
        return _.detect(SORT_BYS, function (sort) { return sort.key == card_store_sort_by });
    },

    otherContexts: function otherContexts () {
        return _.without(SORT_BYS, this.selectedContextTitle());
    },

    changeContext: function changeContext (sort_by) {
        return function() {
            FilterActionCreators.updateSorting(sort_by);
            return false;
        }.bind(this);
    },

    render: function render () {
        var contexts = _.map(this.otherContexts(), function(sort_by, index) {
            return (<li className="nowrap" key={index}>
                        <a href='javascript:void(0)'
                           onClick={this.changeContext(sort_by.key)}>
                           {sort_by.name}
                        </a>
                    </li>);
        }, this);
        return (<div className="soft--left v-middle inline-block drop-down__wrapper search-page__sort-by">
                    <span className="nowrap">
                        {this.selectedContextTitle().name}
                        <i className="fa fa-chevron-down blue-green"></i>
                    </span>
                    <div className="drop-down__el drop-down__el--appears-on-text">
                        <ul className="drop-down__el-inner-box text--left">
                          <li className="nowrap">
                              <a href='javascript:void(0)'>
                                 {this.selectedContextTitle().name}
                                 <i className="fa fa-chevron-down"></i>
                              </a>
                          </li>
                            {contexts}
                        </ul>
                    </div>
                </div>
        );
    },
});

module.exports = CardListSortBy;
