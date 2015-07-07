var SliderActionCreators = require('../../actions/SliderActionCreators'),
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
        return { min: 0, max: 1000, step: 1 };
    },

    getInitialState: function getInitialState () {
        return {
            min: this.props.min, max: this.props.max,
            price_store: PriceStore
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
            start: range,
            range: { min: this.props.min, max: this.props.max },
            step: this.props.step
        });

        slider.noUiSlider.on('change', this.sliderChange);
    },

    sliderChange: function sliderChange (bounds) {
        var slider = $(this.getDOMNode()).find('[data-behavior=slider]')[0];
        bounds     = _.map(bounds, function(bound) { return parseInt(bound, 10)})
        SliderActionCreators.setPriceBounds(bounds);
    },

    getRange: function getRange () {
        if (this.state.price_store.get('bounds')) {
            return [parseInt(this.state.price_store.get('bounds')[0], 10), parseInt(this.state.price_store.get('bounds')[1], 10)];
        } else {
            return [this.props.min, this.props.max];
        }
    },

    render: function render () {
        return (
            <div>
                <div>Prix</div>
                <div data-behavior='slider'></div>
                <div className="grid soft-half--top">
                    <div className="grid__item one-half nowrap">
                        Min. :
                        <strong data-behavior="slider-min-value">{ this.getRange()[0] }</strong>
                        €
                    </div>
                    <div className="grid__item one-half text--right nowrap">
                        Max. :
                        <strong data-behavior="slider-max-value">{ this.getRange()[1] }</strong>
                        €
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = PriceSlider;
