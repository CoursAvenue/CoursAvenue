var FilterStore          = require('../../stores/FilterStore'),
    FilterPanelConstants = require('../../constants/FilterPanelConstants'),
    FluxBoneMixin        = require("../../../mixins/FluxBoneMixin");

var TimeDefaultPanel = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return {
            filter_store:  FilterStore
        };
    },

    selectLessons: function selectLessons () {
        this.state.filter_store.set('time_panel', FilterPanelConstants.TIME_PANELS.LESSON);
    },

    selectTrainings: function selectTrainings () {
        this.state.filter_store.set('time_panel', FilterPanelConstants.TIME_PANELS.TRAINING);
    },

    render: function render () {
        return (
          <div>
              <h2>Quand ?</h2>
              <div className='absolute top right'>close</div>
              <div className="main-container">

                  <div className='one-fourth very-soft inline-block'>
                      <div className='bg-white bordered cursor-pointer soft-half' onClick={ this.selectLessons }>
                          Cours Réguliers
                      </div>
                  </div>

                  <div className='one-fourth very-soft inline-block'>
                      <div className='bg-white bordered cursor-pointer soft-half' onClick={ this.selectTrainings }>
                          Ateliers et stages
                      </div>
                  </div>

              </div>
          </div>
        );
    },
});

module.exports = TimeDefaultPanel;
