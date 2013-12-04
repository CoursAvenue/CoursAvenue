class Pro::SearchTermLogsController < Pro::ProController
  layout 'admin'
  before_action :authenticate_pro_super_admin!

  def index
    @search_term_logs = SearchTermLog.order('count DESC').limit(500)
  end
end
