class RedirectController < ApplicationController
  def show
    url = Rails.cache.fetch("short:#{params[:short_code]}", expires_in: 6.hours) do
      ShortenedUrl.active.find_by(short_code: params[:short_code])
    end

    if url.nil? || url.expired?
      render json: { error: 'URL expired or not found' }, status: :not_found
    else
      AnalyticsJob.perform_later(url.id, request.remote_ip, request.user_agent, request.referer)
      redirect_to url.original_url, allow_other_host: true
    end
  end
end