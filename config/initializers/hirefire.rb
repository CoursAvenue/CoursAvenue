HireFire::Resource.configure do |config|
  config.dyno(:worker) do
    HireFire::Macro::Delayed::Job.queue(mapper: :active_record)
  end

  config.dyno(:mailers) do
    HireFire::Macro::Delayed::Job.queue(:mailers, mapper: :active_record)
  end

  config.dyno(:cards) do
    HireFire::Macro::Delayed::Job.queue(:cards, mapper: :active_record)
  end
end
