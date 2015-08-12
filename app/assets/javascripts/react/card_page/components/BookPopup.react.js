var RequestStore          = require("../stores/RequestStore"),
    StructureStore        = require("../stores/StructureStore"),
    RequestActionCreators = require("../actions/RequestActionCreators"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var BookPopup = React.createClass({

    mixins: [
        FluxBoneMixin(['request_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            request_store: RequestStore,
            structure_store: StructureStore
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
            this.state.request_store.unset('response_popup');
        }
    },

    holidayWarning: function holidayWarning () {
        var new_start_date = moment(this.props.course.start_date, 'YYYY-MM-DD');
        if (new Date() < new_start_date.toDate()) {
            return (<div className="f-size-12">
                        <i>Reprise des cours le {new_start_date.format('DD MMMM').replace(/0([0-9])/, function(a, b) { return b})}</i>
                    </div>);
        }
    },

    getDatepickerStartDate: function getDatepickerStartDate () {
        var new_start_date = moment(this.props.course.start_date, 'YYYY-MM-DD').toDate();
        if (new Date() < new_start_date) {
            return new_start_date;
        }
        return new Date();
    },

    initializeDatepicker: function initializeDatepicker ($datepicker_input) {
        var datepicker_options = {
            format: COURSAVENUE.constants.DATE_FORMAT,
            weekStart: 1,
            language: 'fr',
            autoclose: true,
            todayHighlight: true,
            startDate: this.getDatepickerStartDate()
        };
        $datepicker_input.datepicker(datepicker_options);
        $datepicker_input.datepicker().on('show', COURSAVENUE.datepicker_function_that_hides_inactive_rows);


        var formatted_date = COURSAVENUE.helperMethods.nextWeekDay(this.props.planning.week_day);
        // We check wether the formatted date is not before the datepicker start date
        if (formatted_date.toDate() < this.getDatepickerStartDate()) {
            var days_to_add = 0;
            var new_date = moment(this.getDatepickerStartDate()).day(this.props.planning.week_day);
            if (new_date.toDate() < this.getDatepickerStartDate()) { days_to_add = 7 }
            formatted_date = new_date.day(this.props.planning.week_day + days_to_add);
        }
        $datepicker_input.datepicker('update', formatted_date.toDate());

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

    submitRequest: function submitRequest (event) {
        $(event.currentTarget).prop('disabled', true);
        if (CoursAvenue.currentUser().isLogged()) {
            $dom_node = $(this.getDOMNode());
            RequestActionCreators.submitRequest({
                at_student_home        : !_.isEmpty($dom_node.find('[name="participation_request[at_student_home]"]').val()),
                structure_id           : this.props.course.structure_id,
                course                 : this.props.course,
                date                   : $dom_node.find('[name="participation_request[date]"]').val(),
                planning_id            : this.props.planning.id,
                message                : { body: $dom_node.find('[name="message[body]"]').val() },
                user                   : { phone_number: $dom_node.find('[name="user[phone_number]"]').val() },
                participants_attributes: [ {
                    number: $dom_node.find('[name="participation_request[participants_attributes][0][number]"]').val()
                } ]
            });
        } else {
            CoursAvenue.signUp({
                title: 'Vous devez vous enregistrer pour envoyer votre demande',
                after_sign_up_popup_title: "Demande d'inscription envoyée",
                success: function success (response) {
                    this.submitRequest();
                }.bind(this),
                dismiss: function dismiss() {}
            });
        }
    },

    render: function render () {
        var price_libelle, datepicker = '', place_select;
        if (this.props.course.db_type == 'Course::Training') {
            price_libelle = 'Prix du stage';
        } else {
            price_libelle = this.props.course.min_price.libelle;
            datepicker = (<div className="soft-half--ends bordered--bottom">
                              <div className="grid--full">
                                  <label className="grid__item f-weight-600 v-middle one-half line-height-2 palm-one-whole">
                                      Quel {this.props.planning.date.toLowerCase()} voulez-vous venir ?&nbsp;
                                  </label>
                                  <div className="grid__item v-middle one-half palm-one-whole">
                                      <input type="text"
                                             data-behavior="datepicker"
                                             name="participation_request[date]"
                                             className="datepicker-input very-soft v-middle" />
                                  </div>
                              </div>
                              {this.holidayWarning()}
                          </div>);
        }

        if (this.props.course.teaches_at_home && this.props.course.place) {
            place_select = (<div className="grid--full bordered--bottom soft-half--ends">
                                <label className="grid__item f-weight-600 v-middle one-half line-height-2 palm-one-whole">
                                    Où voulez-vous assister au cours ?
                                </label>
                                <div className="grid__item v-middle one-half palm-one-whole">
                                    <select defaultValue="true" name="participation_request[at_student_home]">
                                        <option value="true">Chez moi</option>
                                        <option value="false">Chez le professeur</option>
                                    </select>
                                </div>
                            </div>);
        }
        return (<div className="bg-white">
                    <div className="soft bordered--bottom bg-gray-light">
                        <div className="delta f-weight-bold">
                            {this.props.course.name}
                        </div>
                        <div className="epsilon f-weight-500 line-height-1-5">
                            {this.props.planning.date}&nbsp;{this.props.planning.time_slot}
                        </div>
                        <div className="epsilon blue-green f-weight-bold line-height-1-5">
                            {price_libelle}&nbsp;:&nbsp;
                            {COURSAVENUE.helperMethods.readableAmount(this.props.course.min_price.amount)}
                        </div>
                    </div>
                    <div className="soft--sides">
                        {datepicker}
                        {place_select}
                        <div className="grid--full bordered--bottom soft-half--ends">
                            <label className="grid__item f-weight-600 v-middle one-half line-height-2 palm-one-whole">
                                Combien serez-vous ?
                            </label>
                            <div className="grid__item v-middle one-half palm-one-whole">
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
                        <div className="grid--full bordered--bottom soft-half--ends">
                            <label className="grid__item f-weight-600 v-middle one-half line-height-2 palm-one-whole">
                                Comment peut-on vous joindre ?
                            </label>
                            <div className="grid__item v-middle one-half palm-one-whole">
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
                                           title=""
                                           defaultValue={(CoursAvenue.currentUser() ? CoursAvenue.currentUser().get('phone_number') : '')}/>
                                </div>
                            </div>
                        </div>
                        <div className="input flush--top push-half--bottom soft-half--top">
                            <div style={{ display: 'none' }}
                                className="soft-half alert alert--warning one-whole push-half--bottom">
                                Pas besoin d'envoyer vos coordonnées de contact, elles seront automatiquement transmises.
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
