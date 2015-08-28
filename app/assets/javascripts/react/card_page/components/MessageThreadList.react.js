var Thread                  = require("./Thread"),
    NewThreadTextarea       = require("./NewThreadTextarea"),
    MessageActionCreators   = require("../actions/MessageActionCreators"),
    StructureActionCreators = require("../actions/StructureActionCreators"),
    StructureStore          = require('../stores/StructureStore'),
    MessageThreadStore      = require('../stores/MessageThreadStore');

var MessageThreadList = React.createClass({

    mixins: [ FluxBoneMixin('thread_store') ],

    componentDidMount: function componentDidMount() {
        StructureActionCreators.setStructure(this.props.structure);
    },

    getInitialState: function getInitialState() {
        return { thread_store: MessageThreadStore, structure_store: StructureStore };
    },

    render: function render () {
        var threads;
        threads = this.state.thread_store.map(function(thread, index) {
            var hr;
            if (index > 0) { hr = (<hr className="push--ends nine-twelfths margin-left-auto" />); }
            return (<div key={ index }>
                        {hr}
                        <Thread thread={thread} key={thread.get('id')}/>
                    </div>);
        });
        return (
            <div id="messages-publics">
                <h2 className="bg-pink bordered--sides bordered--top border-color-pink-darker soft--sides soft-half--ends white flush">
                    <i className="fa-quotes v-middle"></i>&nbsp;
                    <span className="v-middle">
                        Questions Réponses ({ this.state.thread_store.length })
                    </span>
                </h2>
                <div className="bg-white bordered--sides bordered--bottom soft--sides soft--bottom">
                    <div className='epsilon soft--ends'>
                        {"Posez ici vos questions concernant " + this.state.structure_store.get('name') + " ou l’activité qui vous intéresse. Le professeur ou d’autres élèves comme vous pourront y répondre."}
                    </div>
                    <NewThreadTextarea />
                    <article className={(threads.length > 0 ? "soft hard--bottom" : '')}>
                        { threads }
                    </article>
                </div>
            </div>
        );
    }
});

module.exports = MessageThreadList;
