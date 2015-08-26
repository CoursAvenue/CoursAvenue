/* Usage:
 *    mixins: [
 *        Pagination('store_name', action_creator)
 *    ],

 *   You have to implement following functions:
 *      goToPage(page)   => return function
 *      goToPreviousPage => handle action
 *      goToNextPage     => handle action
 *
 *   The store must have:
 *      current_page
 *      total_pages
 *
 *   The store must implement:
 *      isFirstPage
 *      isLasttPage
 *
 *   The action_creator must implement:
 *       goToPage
 *       goToPreviousPage
 *       goToNextPage
 */

var cx                    = require('classnames/dedupe'),
    PAGINATION_RADIUS     = 2;

module.exports = function (store_name, action_creator) {

    return {

        /*
         * Return closure function
         */
        goToPage: function goToPage (page) {
            return function() {
                if (_.isUndefined(page)) { return; }
                // Go to the closest data-react-class, because a pagination will always be
                // encapsulated inside a react component
                $.scrollTo($(this.getDOMNode()).closest('[data-react-class]'), { easing: 'easeOutCubic', duration: 300 });
                setTimeout(function() {
                    action_creator.goToPage(page);
                }, 150);
            }.bind(this)
        },

        goToPreviousPage: function goToPreviousPage () {
            if (this.state[store_name].isFirstPage()) { return; }
            // Go to the closest data-react-class, because a pagination will always be
            // encapsulated inside a react component
            $.scrollTo($(this.getDOMNode()).closest('[data-react-class]'), { easing: 'easeOutCubic', duration: 300 });
            setTimeout(function() {
                action_creator.goToPreviousPage();
            }, 150);
        },

        goToNextPage: function goToNextPage () {
            if (this.state[store_name].isLastPage()) { return; }
            // Go to the closest data-react-class, because a pagination will always be
            // encapsulated inside a react component
            $.scrollTo($(this.getDOMNode()).closest('[data-react-class]'), { easing: 'easeOutCubic', duration: 300 });
            setTimeout(function() {
                action_creator.goToNextPage();
            }, 150);
        },

        /* we want to show buttons for the first and last pages, and the
         * pages in a radius around the current page. So we will skip pages
         * that don't meet that criteria */
        canSkipPage: function canSkipPage (page) {
            var current_page  = this.state[store_name].current_page,
                last_page     = this.state[store_name].total_pages,
                out_of_bounds = (current_page - PAGINATION_RADIUS > page || page > current_page + PAGINATION_RADIUS),
                bookend       = (page == 1 || page == last_page);

            return (!bookend && out_of_bounds);
        },

        /* the query_strings are built in the paginated collection view */
        buildPaginationButtons: function buildPaginationButtons () {
            var skipped = false,
                buttons = [];

            _.times(this.state[store_name].total_pages, function(index) {
                var current_page = index + 1;

                if (this.canSkipPage(current_page)) { // 1, ..., 5, 6, 7, ..., 9
                    skipped = true;
                } else {
                    if (skipped) { // push on an ellipsis if we've skipped any pages
                        buttons.push({ label: '...', disabled: true });
                    }

                    buttons.push({ // push the current page
                        label: current_page,
                        page:  current_page,
                        active: (current_page == current_page)
                        //query: (data.query_strings ? data.query_strings[current_page] : '')
                    });

                    skipped = false;
                }
            }.bind(this));

            return buttons;
        },

        render: function render () {
            var back_class = cx('pagination__prev', { 'visibility-hidden': this.state[store_name].isFirstPage() });
            var next_class = cx('pagination__next', { 'visibility-hidden': this.state[store_name].length == 0 || this.state[store_name].isLastPage() });
            var buttons = _.map(this.buildPaginationButtons(), function(button, index) {
                var button_classes = cx('pagination__page',
                                        { 'pagination__page--active': (this.state[store_name].current_page == button.page),
                                          'pagination__page--disabled': button.disabled });
                return (<a className={button_classes}
                            key={index}
                            href="javascript:void(0)"
                            onClick={this.goToPage(button.page)}>
                            {button.label}
                        </a>);
            }.bind(this));
            return (
              <div className={ cx("flexbox palm-block palm-text--center palm-one-whole pagination", { 'pagination--large': this.state.large }) }>
                  <div className="flexbox__item palm-block palm-text--center palm-one-whole two-twelfths">
                      <a className={back_class}
                         href="javascript:void(0)"
                         onClick={this.goToPreviousPage}>
                         <i className="fa fa-chevron-left"></i>
                         Précédent
                      </a>
                  </div>
                  <div className="flexbox__item palm-block palm-text--center palm-one-whole eight-twelfths nowrap text--center">
                      {buttons}
                  </div>
                  <div className="flexbox__item palm-block palm-text--center palm-one-whole two-twelfths text--right">
                      <a className={next_class}
                         href="javascript:void(0)"
                         onClick={this.goToNextPage}>
                         Suivant
                         <i className="fa fa-chevron-right"></i>
                      </a>
                  </div>
              </div>
            );
        }
    }
}
