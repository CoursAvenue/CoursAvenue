class Pro::ClickLogsController < Pro::ProController
  layout 'admin'

  def index
    @click_logs = ClickLog.count(order: 'structure_id', group: ['structure_id'])
  end
end
