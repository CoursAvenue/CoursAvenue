class Pro::SearchTermLogsController < Pro::ProController
  layout 'admin'
  before_action :authenticate_pro_super_admin!

  def index
    # @search_term_logs = SearchTermLog.order('name ASC').group('name').count
    # @search_term_logs = @search_term_logs.reject { |search_term_log, count| count < 4 }
    # @search_term_logs = @search_term_logs.sort_by(&:last).reverse

    @search_term_logs = SearchTermLog.where( SearchTermLog.arel_table[:name].matches("filtre%") ).order('name ASC').group('name').count
    @search_term_logs = @search_term_logs.sort_by(&:last).reverse
  end
end
