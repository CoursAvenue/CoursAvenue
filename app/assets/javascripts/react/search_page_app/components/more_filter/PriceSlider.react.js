var SliderActionCreators = require('../../actions/SliderActionCreators'),
    CardStore             = require('../../stores/CardStore'),
    PriceStore           = require('../../stores/PriceStore'),
    FluxBoneMixin        = require("../../../mixins/FluxBoneMixin");

var PriceSlider = React.createClass({
    mixins: [
        FluxBoneMixin(['price_store'])
    ],

    propTypes: {
        min:  React.PropTypes.number,
        max:  React.PropTypes.number,
        step: React.PropTypes.number
    },

    getDefaultProps: function getDefaultProps () {
        return { min: 0, max: 1000, step: 5 };
    },

    getInitialState: function getInitialState () {
        return {
            min: this.props.min, max: this.props.max,
            price_store: PriceStore,
            card_store: CardStore
        };
    },

    componentDidUpdate: function componentDidUpdate () {
        var slider = $('[data-behavior=slider]')[0];
        slider.noUiSlider.set(this.getRange());
    },

    componentDidMount: function componentDidMount () {
        var range   = this.getRange();
        var slider = $(this.getDOMNode()).find('[data-behavior=slider]')[0];

        noUiSlider.create(slider, {
            connect: true,
            start  : range,
            range  : { min: this.props.min, max: this.props.max },
            step   : this.props.step
        });

        slider.noUiSlider.on('change', this.sliderChange);
        slider.noUiSlider.on('slide', this.sliderChange);
    },

    sliderChange: function sliderChange (bounds) {
        var slider = $(this.getDOMNode()).find('[data-behavior=slider]')[0];
        bounds     = _.map(bounds, function(bound) { return parseInt(bound, 10)})
        SliderActionCreators.setPriceBounds(bounds);
    },

    getRange: function getRange () {
        if (this.state.price_store.get('bounds')) {
            var min_price = parseInt(this.state.price_store.get('bounds')[0], 10);
            min_price = (min_price == 0 ? 'Gratuit' : min_price + '€');
            return [min_price, parseInt(this.state.price_store.get('bounds')[1], 10)];
        } else {
            return [this.props.min, this.props.max];
        }
    },

    render: function render () {
        var title = (this.state.card_store.context == 'training' ? "Prix du stage" : "Prix de la séance d'essai");
        return (
            <div>
                <div className="search-page-filter-more__title">{title}</div>
                <div className="soft--sides">
                    <div data-behavior='slider'></div>
                </div>
                <div className="grid soft-half--sides">
                    <div className="grid__item one-half nowrap search-page-filter-more__slider-desc text--left">
                        <span data-behavior="slider-min-value">{ this.getRange()[0] }</span>
                    </div>
                    <div className="grid__item one-half text--right nowrap search-page-filter-more__slider-desc text--left">
                        <span data-behavior="slider-max-value">{ this.getRange()[1] }</span>
                        €
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = PriceSlider;
