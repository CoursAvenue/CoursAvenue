var FullPageLoading = React.createClass({
    render: function render () {
        return (
            <div class="on-top-of-the-world north west fixed one-whole bg-black-faded height-100-percent text--center flexbox">
               <div class="flexbox__item v-middle">
                   <div class="alpha white">
                        <strong>{this.props.text}</strong>
                        <div class="text--center">
                            <img src="<%= asset_path('gifs/loading-bubbles.svg') %>" alt="Chargement en cours..." />
                        </div>
                   </div>
               </div>
            </div>
        );
    }
});

module.exports = FullPageLoading;
