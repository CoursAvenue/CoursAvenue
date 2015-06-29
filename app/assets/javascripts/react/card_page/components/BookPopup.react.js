var CourseStore           = require("../stores/CourseStore"),
    PlanningStore         = require("../stores/PlanningStore"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var BookPopup = React.createClass({

    mixins: [
        FluxBoneMixin(['course_store', 'planning_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            course_store: CourseStore,
            planning_store: PlanningStore
        };
    },

    // Trigger view in a popup if a planning is selected
    componentDidUpdate: function componentDidUpdate () {
        var selected_planning = this.selectedPlanning();
        if (selected_planning) {
            $popup = $(this.getDOMNode()).removeClass('hidden');
            $.magnificPopup.open({
                  items: {
                      src: $popup,
                      type: 'inline'
                  }
            });
            var $datepicker_input = $popup.find('[data-behavior=datepicker]');
            this.initializeDatepicker($datepicker_input);
        }
    },

    initializeDatepicker: function initializeDatepicker ($datepicker_input) {
        var selected_planning = this.selectedPlanning();
        var datepicker_options = {
            format: COURSAVENUE.constants.DATE_FORMAT,
            weekStart: 1,
            language: 'fr',
            autoclose: true,
            todayHighlight: true,
            startDate: new Date()
        };
        $datepicker_input.datepicker(datepicker_options);
        if (selected_planning.get('next_date')) {
            var formatted_date = moment(selected_planning.get('next_date'), "DD/MM/YYYY").format(COURSAVENUE.constants.MOMENT_DATE_FORMAT);
            $datepicker_input.datepicker('update', formatted_date);
        } else {
            $datepicker_input.datepicker('update', moment().add(7, 'days').toDate());
        }
        // Disable days of week
        var days_of_week = [0,1,2,3,4,5,6];
        if (this.state.course_store.get('db_type') == 'Course::Private') {
            _.each(this.state.course_store.get('plannings'), function(planning) {
                if (days_of_week.indexOf(planning.week_day) != -1) {
                    days_of_week.splice(days_of_week.indexOf(planning.week_day), 1);
                }
            });
        } else {
            days_of_week.splice(days_of_week.indexOf(selected_planning.get('week_day')), 1);
        }
        $datepicker_input.datepicker('setDaysOfWeekDisabled', days_of_week);
    },

    selectedPlanning: function selectedPlanning () {
        return this.state.planning_store.findWhere({ selected: true });
    },

    render: function render () {
        var selected_planning = this.selectedPlanning();
        if (selected_planning) {
            return (<div className="hidden center-block bg-white" style={{ maxWidth: '450px' }}>
                        <div className="soft">
                            <div className="delta f-weight-bold">
                                {this.state.course_store.get('name')}
                            </div>
                            <div className="epsilon green f-weight-bold line-height-1-5">
                                {this.state.course_store.get('min_price').libelle}&nbsp;:&nbsp;
                                {COURSAVENUE.helperMethods.readableAmount(this.state.course_store.get('min_price').amount)}
                            </div>
                        </div>
                        <div className="grid--full bordered--top">
                            <div className="grid__item v-middle four-twelfths soft--sides soft-half--ends bordered--right">
                                Date
                            </div>
                            <div className="grid__item v-middle eight-twelfths soft-half--sides">
                                {selected_planning.get('date')}&nbsp;{selected_planning.get('time_slot')}
                            </div>
                        </div>
                        <div className="grid--full bordered--top">
                            <div className="grid__item v-middle four-twelfths soft--sides soft-half--ends bordered--right">
                                Jour
                            </div>
                            <div className="grid__item v-middle eight-twelfths soft-half--sides">
                                <input type="text"
                                       data-behavior="datepicker"
                                       name="participation_request[date]"
                                       className="datepicker-input v-middle" />
                            </div>
                        </div>
                        <div className="grid--full bordered--top">
                            <div className="grid__item v-middle four-twelfths soft--sides soft-half--ends bordered--right">
                                Lieu
                            </div>
                            <div className="grid__item v-middle eight-twelfths soft-half--sides">
                                <span className="epsilon inline"
                                      data-element="address-info"
                                      data-toggle="popover"
                                      data-placement="top"
                                      data-html="true"
                                      data-content={selected_planning.get('address_with_info')}
                                      data-original-title=""
                                      title="">
                                      {selected_planning.get('address_name')}
                                </span>
                            </div>
                        </div>
                        <div className="grid--full bordered--top">
                            <div className="grid__item v-middle four-twelfths soft--sides soft-half--ends bordered--right">
                                Nb participants
                            </div>
                            <div className="grid__item v-middle eight-twelfths soft-half--sides">
                                <select name="participation_request[participants_attributes][0][number]">
                                    <option value="1" selected>1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                    <option value="5">5</option>
                                    <option value="6">6</option>
                                    <option value="7">7</option>
                                </select>
                            </div>
                        </div>
                        <div className="soft--sides">
                            <div className="input-addon push-half--bottom">
                                <div className="input-prefix">
                                    <i className="fa-phone-o"></i>
                                </div>
                                <input type="text" className="input--large one-whole hard--right"
                                       name="user[phone_number]"
                                       placeholder="Votre téléphone (confidentiel)"
                                       data-toggle="popover"
                                       data-content="Nous vous recommandons de laisser votre numéro de portable : si la séance est annulée ou modifiée, un SMS pourra vous être envoyé."
                                       data-trigger="hover"
                                       data-placement="left"
                                       data-original-title=""
                                       title="" />
                            </div>
                            <div className="input flush--top push-half--bottom">
                                <div style={{ display: 'none' }}
                                    class="soft-half alert alert--warning one-whole push-half--bottom">
                                    Pas besoin d'envoyer vos coordonnées de contact par message : une fois l'inscription confirmée, elles seront automatiquement partagées.
                                </div>
                                <textarea name="message[body]"
                                          id=""
                                          cols="30"
                                          rows="12"
                                          className="one-whole input--large"
                                          style={{ height: '135px' }}
                                          data-behavior="autoresize"
                                          >
                                        {"Bonjour,\n\nJe souhaiterais m'inscrire pour une première séance : pouvez-vous m'envoyer toute information utile (tenue exigée, matériel requis, etc.) ?\n\nMerci et à très bientôt !"}
                                </textarea>
                            </div>

                            <button type="submit"
                                    className="btn btn--green btn--full push-half--bottom"
                                    data-disable-with="Message en cours d'envoi...">
                                {"Envoyer ma demande d'inscription"}
                            </button>
                        </div>
                    </div>
            );
        } else {
            return (<div></div>);
        }
    }
});

module.exports = BookPopup;
