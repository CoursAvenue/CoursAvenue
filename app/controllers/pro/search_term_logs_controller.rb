class Pro::SearchTermLogsController < Pro::ProController
  layout 'admin'
  before_action :authenticate_pro_super_admin!

  def index
    @search_term_logs = SearchTermLog.count(order: 'name', group: ['name'])
    @search_term_logs = @search_term_logs.reject{|search_term_log| search_term_log.length < 4}
  end
end
