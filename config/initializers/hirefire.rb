HireFire::Resource.configure do |config|
  config.dyno(:dj_worker) do
    HireFire::Macro::Delayed::Job.queue
  end
end
