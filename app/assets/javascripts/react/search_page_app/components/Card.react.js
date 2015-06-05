var SearchPageConstants  = require('../constants/SearchPageConstants'),
    CardActionCreators   = require('../actions/CardActionCreators');

var ActionTypes = SearchPageConstants.ActionTypes;

Card = React.createClass({

    highlightMaker: function highlightMaker (event) {
        CardActionCreators.highlightMaker({ event: event, card: this.props.card });
    },

    unHighlightMaker: function unHighlightMaker (event) {
        CardActionCreators.unHighlightMaker({ event: event, card: this.props.card });
    },

    render: function render () {
        var gift_classes = { gray: this.props.card.get('is_open_for_trial')}
        return (
          <div className="soft-half one-quarter palm-one-whole lap-one-half inline-block v-top"
              onMouseEnter={ this.highlightMaker } onMouseLeave={ this.unHighlightMaker }>
              <div className="bg-white bordered">
                  <div className="bordered--bottom">
                      <img className="block one-whole"
                           src={this.props.card.get('header_image')}
                           height="100"/>
                  </div>
                  <div className="soft-half">
                      <img className="rounded--circle center-block push-half--bottom"
                            style={{ marginTop: '-35px' }}
                            width="50"
                           src={this.props.card.get('structure_logo_url')} />
                      <div className="text--center">
                          <div className="push-half--bottom gray">
                              <a href={Routes.structure_path(this.props.card.get('structure_slug'))}
                                 className="semi-muted-link">
                                  {this.props.card.get('structure_name')}
                              </a>
                          </div>
                          <h4>{this.props.card.get('course_name')}</h4>
                      </div>
                      <div>
                          <i className="fa fa-star"></i>
                          <i className="fa fa-star"></i>
                          <i className="fa fa-star"></i>
                          <i className="fa fa-star"></i>
                          <i className="fa fa-star"></i>
                          ({this.props.card.get('comments_count')} avis)
                      </div>
                  </div>
                  <div className="flexbox bordered--top">
                      <div className="flexbox__item text--center very-soft one-quarter bordered--right">
                          <i className="fa fa-2x fa-map-marker"></i>
                      </div>
                      <div className="flexbox__item text--center very-soft one-quarter bordered--right">
                          <i className="fa fa-2x fa-clock"></i>
                      </div>
                      <div className="flexbox__item text--center very-soft one-quarter bordered--right">
                          <i className="fa fa-2x fa-trophy"></i>
                      </div>
                      <div className={gift_classes + " flexbox__item text--center very-soft one-quarter"}>
                          <i className="fa fa-2x fa-gift"></i>
                      </div>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = Card;
