class AddIpToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :ip_address, :string
    bar = ProgressBar.new Statistic.where.not(user_fingerprint: nil).count
    Statistic.where.not(user_fingerprint: nil).each do |stat|
      bar.increment!
      stat.update_column :ip_address, stat.user_fingerprint
    end
  end
end
