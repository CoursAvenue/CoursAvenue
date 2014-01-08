class Pro::ClickLogsController < Pro::ProController
  layout 'admin'

  def index
    @click_logs         = ClickLog.count(order: 'structure_id', group: ['structure_id'])
    @click_logs_per_day = ClickLog.count(:order => "DATE(created_at) ASC", :group => ["DATE(created_at)"])
  end
end
