var SliderActionCreators = require('../../actions/SliderActionCreators');

var PriceSlider = React.createClass({
    propTypes: {
        min:  React.PropTypes.number,
        max:  React.PropTypes.number,
        step: React.PropTypes.number
    },

    getDefaultProps: function getDefaultProps () {
        return { min: 0, max: 1000, step: 1 };
    },

    getInitialState: function getInitialState () {
        return { min: this.props.min, max: this.props.max };
    },

    componentDidMount: function componentDidMount () {
        var range   = [this.props.min, this.props.max];
        var $slider = $('[data-behavior=slider]');

        $slider.noUiSlider({
            range: range,
            start: range,
            step: this.props.step
        });

        $slider.on('change', this.sliderChange);
    },

    sliderChange: function sliderChange () {
        var bounds = _.map($('[data-behavior=slider]').val(), function(value) {
            return parseFloat(value, 10);
        });
        this.setState({ min: bounds[0], max: bounds[1] });
        SliderActionCreators.setPriceBounds(bounds);
    },

    render: function () {
        return (
            <div>
                <div>Prix</div>
                <div data-behavior='slider'></div>
                <div className="grid soft-half--top">
                    <div className="grid__item one-half nowrap">
                        Min. :
                        <strong data-behavior="slider-min-value">{ this.state.min }</strong>
                        €
                    </div>
                    <div className="grid__item one-half text--right nowrap">
                        Max. :
                        <strong data-behavior="slider-max-value">{ this.state.max }</strong>
                        €
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = PriceSlider;
