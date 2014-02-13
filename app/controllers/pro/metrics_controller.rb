# encoding: utf-8
class Pro::MetricsController < Pro::ProController

  def comments
    render json: Comment.order('created_at DESC').limit(10)
  end

  def comments_count
    if params[:today]
      render json: Comment.where{created_at > Date.today}.count
    else
      render json: Comment.count
    end
  end

  def jpos
    render json: Course::Open.order('created_at DESC').limit(10)
  end
end
