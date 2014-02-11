# encoding: utf-8
class Pro::MetricsController < Pro::ProController

  def comments
    render json: Comment.order('created_at DESC').limit(10)
  end
end
