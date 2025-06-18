class DashboardController < ActionController::Base
  layout 'application'  # explicitly use application layout

  def index
    @urls = ShortenedUrl.order(created_at: :desc)
  end
end