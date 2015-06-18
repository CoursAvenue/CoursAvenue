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

    componentDidMount: function componentDidMount () {
        var range   = [this.props.min, this.props.max];
        var $slider = $('[data-behavior=slider]');

        $slider.noUiSlider({
            range: range,
            start: range,
            step: 1
        });

        $slider.on('change', this.sliderChange);
    },

    sliderChange: function sliderChange () {
        var bounds = _.map($('[data-behavior=slider]').val(), function(value) {
            return parseFloat(value, 10);
        });
        SliderActionCreators.setPriceBounds(bounds);
    },

    render: function () {
        return (
            <div>
                <div>Prix</div>
                <div data-behavior='slider'></div>
            </div>
        );
    },
});

module.exports = PriceSlider;
