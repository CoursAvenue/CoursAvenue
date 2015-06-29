var RequestStore          = require("../stores/RequestStore"),
    RequestActionCreators = require("../actions/RequestActionCreators"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var BookPopup = React.createClass({

    mixins: [
        FluxBoneMixin(['request_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            request_store: RequestStore
        };
    },

    // Trigger view in a popup if a planning is selected
    componentDidMount: function componentDidMount () {
        var $datepicker_input = $(this.getDOMNode()).find('[data-behavior=datepicker]');
        this.initializeDatepicker($datepicker_input);
    },

    componentDidUpdate: function componentDidUpdate () {
        if (this.state.request_store.get('response_popup')) {
            $.magnificPopup.open({
                  items: {
                      src: this.state.request_store.get('response_popup'),
                      type: 'inline'
                  }
            });
        }
    },

    initializeDatepicker: function initializeDatepicker ($datepicker_input) {
        var datepicker_options = {
            format: COURSAVENUE.constants.DATE_FORMAT,
            weekStart: 1,
            language: 'fr',
            autoclose: true,
            todayHighlight: true,
            startDate: new Date()
        };
        $datepicker_input.datepicker(datepicker_options);
        if (this.props.planning.next_date) {
            var formatted_date = moment(this.props.planning.next_date, "DD/MM/YYYY").format(COURSAVENUE.constants.MOMENT_DATE_FORMAT);
            $datepicker_input.datepicker('update', formatted_date);
        } else {
            $datepicker_input.datepicker('update', moment().add(7, 'days').toDate());
        }
        // Disable days of week
        var days_of_week = [0,1,2,3,4,5,6];
        if (this.props.course.db_type == 'Course::Private') {
            _.each(this.props.course.plannings, function(planning) {
                if (days_of_week.indexOf(planning.week_day) != -1) {
                    days_of_week.splice(days_of_week.indexOf(planning.week_day), 1);
                }
            });
        } else {
            days_of_week.splice(days_of_week.indexOf(this.props.planning.week_day), 1);
        }
        $datepicker_input.datepicker('setDaysOfWeekDisabled', days_of_week);
    },

    submitRequest: function submitRequest () {
        if (CoursAvenue.currentUser().isLogged()) {
            RequestActionCreators.submitRequest({
                structure_id           : this.props.course.structure_id,
                course                 : this.props.course,
                planning               : this.props.planning,
                message                : { body: $(this.getDOMNode()).find('[name="message[body]"]').val() },
                user                   : { phone_number: $(this.getDOMNode()).find('[name="user[phone_number]"]').val() },
                participants_attributes: [ {
                    number: $(this.getDOMNode()).find('[name="participation_request[participants_attributes][0][number]"]').val()
                } ]
            });
        } else {
            CoursAvenue.signUp({
                title: 'Vous devez vous enregistrer pour envoyer votre demande',
                after_sign_up_popup_title: "Demande d'inscription envoyée",
                success: function success (response) {
                    this.submitRequest();
                }.bind(this),
                dismiss: function dismiss() {
                    debugger
                }
            });
        }
    },

    render: function render () {
        return (<div className="bg-white">
                    <div className="soft bordered--bottom bg-gray-light">
                        <div className="delta f-weight-bold">
                            {this.props.course.name}
                        </div>
                        <div className="epsilon f-weight-500 line-height-1-5">
                            {this.props.planning.date}&nbsp;{this.props.planning.time_slot}
                        </div>
                        <div className="epsilon green f-weight-bold line-height-1-5">
                            {this.props.course.min_price.libelle}&nbsp;:&nbsp;
                            {COURSAVENUE.helperMethods.readableAmount(this.props.course.min_price.amount)}
                        </div>
                    </div>
                    <div className="soft--sides">
                        <div className="grid--full">
                            <label className="grid__item f-weight-bold v-middle one-half soft-half--ends line-height-2">
                                Quel {this.props.planning.date.toLowerCase()} voulez-vous venir ?&nbsp;
                            </label>
                            <div className="grid__item v-middle one-half">
                                <input type="text"
                                       data-behavior="datepicker"
                                       name="participation_request[date]"
                                       className="datepicker-input very-soft v-middle" />
                            </div>
                        </div>
                        <div className="grid--full bordered--top">
                            <label className="grid__item f-weight-bold v-middle one-half soft-half--ends line-height-2">
                                Combien serez-vous ?
                            </label>
                            <div className="grid__item v-middle one-half">
                                <select defaultValue="1" name="participation_request[participants_attributes][0][number]">
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                    <option value="5">5</option>
                                    <option value="6">6</option>
                                    <option value="7">7</option>
                                </select>
                            </div>
                        </div>
                        <div className="grid--full bordered--top">
                            <label className="grid__item f-weight-bold v-middle one-half soft-half--ends line-height-2">
                                Comment peut-on vous joindre ?
                            </label>
                            <div className="grid__item v-middle one-half">
                                <div className="input-addon">
                                    <div className="input-prefix">
                                        <i className="fa-phone-o"></i>
                                    </div>
                                    <input type="text" className="one-whole hard--right"
                                           name="user[phone_number]"
                                           placeholder="Votre téléphone (confidentiel)"
                                           data-toggle="popover"
                                           data-content="Nous vous recommandons de laisser votre numéro de portable : si la séance est annulée ou modifiée, un SMS pourra vous être envoyé."
                                           data-trigger="hover"
                                           data-placement="left"
                                           data-original-title=""
                                           title="" />
                                </div>
                            </div>
                        </div>
                        <div className="input flush--top push-half--bottom soft-half--top bordered--top">
                            <div style={{ display: 'none' }}
                                className="soft-half alert alert--warning one-whole push-half--bottom">
                                Pas besoin d'envoyer vos coordonnées de contact par message : une fois l'inscription confirmée, elles seront automatiquement partagées.
                            </div>
                            <label className="f-weight-bold soft-half--bottom">
                                {"Accompagnez votre demande d'un petit message :"}
                            </label>
                            <textarea name="message[body]"
                                      id=""
                                      cols="30"
                                      rows="12"
                                      className="one-whole input--large"
                                      style={{ height: '135px' }}
                                      data-behavior="autoresize"
                                      defaultValue={"Bonjour,\n\nJe souhaiterais m'inscrire pour une première séance : pouvez-vous m'envoyer toute information utile (tenue exigée, matériel requis, etc.) ?\n\nMerci et à très bientôt !"}>
                            </textarea>
                        </div>

                        <button onClick={this.submitRequest}
                                data-disable-with="Inscription en cours..."
                                className="btn btn--green btn--full push-half--bottom">
                            {"Envoyer ma demande d'inscription"}
                        </button>
                    </div>
                </div>
        );
    }
});

module.exports = BookPopup;
