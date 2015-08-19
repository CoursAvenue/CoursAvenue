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
        var new_start_date = moment(this.props.course.get('start_date'), 'YYYY-MM-DD');
        if (new Date() < new_start_date.toDate()) {
            return (<div className="f-size-12">
                        <i>Reprise des cours le {new_start_date.format('DD MMMM').replace(/0([0-9])/, function(a, b) { return b})}</i>
                    </div>);
        }
    },

    getDatepickerStartDate: function getDatepickerStartDate () {
        var new_start_date = moment(this.props.course.get('start_date'), 'YYYY-MM-DD').toDate();
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

        if (this.props.planning.week_day) {
            var formatted_date = COURSAVENUE.helperMethods.nextWeekDay(this.props.planning.week_day);
            // We check wether the formatted date is not before the datepicker start date
            if (formatted_date.toDate() < this.getDatepickerStartDate()) {
                var days_to_add = 0;
                var new_date = moment(this.getDatepickerStartDate()).day(this.props.planning.week_day || 1);
                if (new_date.toDate() < this.getDatepickerStartDate()) { days_to_add = 7 }
                formatted_date = new_date.day(this.props.planning.week_day + days_to_add);
            }
            $datepicker_input.datepicker('update', formatted_date.toDate());
            // Disable days of week
            var days_of_week = [0,1,2,3,4,5,6];
            days_of_week.splice(days_of_week.indexOf(this.props.planning.week_day), 1);
            $datepicker_input.datepicker('setDaysOfWeekDisabled', days_of_week);
        } else {
            $datepicker_input.datepicker('update', this.getDatepickerStartDate());
        }
    },

    submitRequest: function submitRequest (event) {
        var user_params;
        if (event) { $(event.currentTarget).prop('disabled', true); }
        if (this.props.dont_register || CoursAvenue.currentUser().isLogged()) {
            $dom_node = $(this.getDOMNode());
            user_params = { phone_number: $dom_node.find('[name="user[phone_number]"]').val() }
            if (this.props.dont_register) {
                user_params.first_name = $dom_node.find('[name="user[first_name]"]').val();
                user_params.last_name  = $dom_node.find('[name="user[last_name]"]').val();
                user_params.email      = $dom_node.find('[name="user[email]"]').val();
            }
            RequestActionCreators.submitRequest({
                at_student_home        : !_.isEmpty($dom_node.find('[name="participation_request[at_student_home]"]').val()),
                structure_id           : this.props.course.get('structure_id'),
                course_id              : this.props.course.get('id'),
                start_hour             : $dom_node.find('[name="participation_request[start_hour]"]').val(),
                start_min              : $dom_node.find('[name="participation_request[start_min]"]').val(),
                date                   : $dom_node.find('[name="participation_request[date]"]').val(),
                planning_id            : this.props.planning.id,
                message                : { body: $dom_node.find('[name="message[body]"]').val() },
                user                   : user_params,
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

    getTimeSelect: function getTimeSelect () {
        return (<div className="inline-block v-middle">
                  &nbsp;à&nbsp;
                  <select name="participation_request[start_hour]">
                      {_.map(_.range(6, 23), function(index) {
                          return (<option value={index}>{(index < 10 ? '0' + index : index)}</option>);
                      })}
                  </select>
                  &nbsp;h&nbsp;
                  <select name="participation_request[start_min]">
                      <option value="00">00</option>
                      <option value="15">15</option>
                      <option value="30">30</option>
                      <option value="4s5">45</option>
                  </select>
                </div>);
    },

    /*
     * User do not have to register to CoursAvenue if he is on /reservation page
     */
    userInfo: function userInfo () {
        if (this.props.dont_register) {
            return (<div className="bordered--bottom soft-half--bottom">
                      <div className="soft-half--ends">
                          <label className="f-weight-600 v-middle line-height-2">
                              Quelques informations sur vous :
                          </label>
                      </div>
                      <div className="grid push-half--bottom">
                          <div className="grid__item one-half palm-one-whole">
                              <input className="one-whole"
                                      name="user[first_name]"
                                      placeholder="Votre prénom" />
                          </div>
                          <div className="grid__item one-half palm-one-whole">
                              <input className="one-whole"
                                      name="user[last_name]"
                                      placeholder="Votre nom" />
                          </div>
                      </div>
                      <div className="grid">
                          <div className="grid__item one-half palm-one-whole">
                              <div className="input-addon">
                                  <div className="input-prefix">
                                      <i className="fa-envelope-o"></i>
                                  </div>
                                  <input className="one-whole"
                                          name="user[email]"
                                          placeholder="Votre email" />
                              </div>
                          </div>
                          <div className="grid__item one-half palm-one-whole">
                              <div className="input-addon">
                                  <div className="input-prefix">
                                      <i className="fa-phone-o"></i>
                                  </div>
                                  <input type="text" className="one-whole hard--right"
                                         name="user[phone_number]"
                                         placeholder="Votre téléphone (confidentiel)" />
                              </div>
                          </div>
                      </div>
                  </div>);
        } else {
            return (<div className="grid--full bordered--bottom soft-half--ends">
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
                    </div>);
        }
    },

    render: function render () {
        var price_libelle, datepicker = '', place_select, date_label, planning_details, time_select;
        if (this.props.course.get('db_type') == 'Course::Training') {
            price_libelle = 'Prix du stage';
        } else {
            price_libelle = this.props.course.get('min_price').libelle;
            if (this.props.course.get('on_appointment')) {
                date_label = "Quand voulez-vous venir ? ";
                time_select = this.getTimeSelect();
            } else {
                date_label = "Quel " + this.props.planning.date.toLowerCase() + " voulez-vous venir ? ";
            }
            datepicker = (<div className="soft-half--ends bordered--bottom">
                              <div className="grid--full">
                                  <label className="grid__item f-weight-600 v-middle one-half line-height-2 palm-one-whole">
                                      {date_label}
                                  </label>
                                  <div className="grid__item v-middle one-half palm-one-whole">
                                      <input type="text"
                                             data-behavior="datepicker"
                                             name="participation_request[date]"
                                             className="datepicker-input very-soft v-middle" />
                                      {time_select}
                                  </div>
                              </div>
                              {this.holidayWarning()}
                          </div>);
        }

        if (this.props.course.get('teaches_at_home') && this.props.course.get('place')) {
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
        if (!this.props.course.get('on_appointment')) {
            planning_details = (<div className="epsilon f-weight-500 line-height-1-5">
                                    {this.props.planning.date}&nbsp;{this.props.planning.time_slot}
                                </div>)
        }
        return (<div className="bg-white">
                    <div className="soft bordered--bottom bg-gray-light">
                        <div className="delta f-weight-bold">
                            {this.props.course.get('name')}
                        </div>
                        {planning_details}
                        <div className="epsilon blue-green f-weight-bold line-height-1-5">
                            {price_libelle}&nbsp;:&nbsp;
                            {COURSAVENUE.helperMethods.readableAmount(this.props.course.get('min_price').amount)}
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
                        { this.userInfo() }
                        <div className="input flush--top push-half--bottom soft-half--top">
                            <div style={{ display: 'none' }}
                                className="soft-half alert alert--warning one-whole push-half--bottom">
                                {"Pas besoin d'envoyer vos coordonnées de contact, elles seront automatiquement transmises."}
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
