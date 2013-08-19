HireFire::Resource.configure do |config|
  config.dyno(:resque_worker) do
    HireFire::Macro::Resque.queue
  end

  config.dyno(:dj_worker) do
    HireFire::Macro::Delayed::Job.queue
  end
end
