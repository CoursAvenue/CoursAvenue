class Pro::SearchTermLogsController < Pro::ProController
  layout 'admin'
  before_action :authenticate_pro_super_admin!

  def index
    @search_term_logs = SearchTermLog.count(order: 'name', group: ['name'])
  end
end
