/*
    Usage:
    #short-version
      This is...
    #long-version
      This is the long version
    %a{ data: { behavior: 'show-long-version' long-version: "#long-version" short-version: "#short-version" } }
      + Plus
*/

$(function() {
    // $('[data-behavior=show-long-version]').showLongVersion();

    $('body').on('click', '[data-behavior=show-long-version]', function(event) {
        this.$link          = $(this);
        $(this.$link.data('short-version')).hide();
        $(this.$link.data('long-version')).removeClass('hidden');
        this.$link.remove();
        return false;
    });
});
