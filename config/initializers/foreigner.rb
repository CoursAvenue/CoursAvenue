ActiveSupport.on_load :active_record do
  Foreigner.load
end
