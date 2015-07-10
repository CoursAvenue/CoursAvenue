var AnswerStore   = require('../stores/AnswerStore'),
    MainSubject   = require('./results/MainSubject'),
    SubjectList   = require('./results/SubjectList'),
    CourseSearch  = require('./results/CourseSearch'),
    FluxBoneMixin = require('../../mixins/FluxBoneMixin');

var Results = React.createClass({
    mixins: [
        FluxBoneMixin(['answer_store'])
    ],

    getInitialState: function getInitialState () {
        return { answer_store: AnswerStore };
    },

    render: function render () {
        return (
            <div className='section relative one-whole relative white full-screen-item bg-cover'>
                <MainSubject />
                <SubjectList />
                <CourseSearch />
            </div>
        );
    },
});

module.exports = Results;
