class RedirectController < ApplicationController
  def show
    url = Rails.cache.fetch("short:#{params[:short_code]}", expires_in: 6.hours) do
      ShortenedUrl.active.find_by(short_code: params[:short_code])
    end

    return render json: { error: 'URL expired or not found' }, status: :not_found if url.nil? || url.expired?

    # Check for passcode protection
    if url.passcode_digest.present?
      input_passcode = params[:passcode]
      if input_passcode.blank? || !url.authenticate_passcode(input_passcode)
        return render json: { error: 'Invalid or missing passcode' }, status: :unauthorized
      end
    end

    AnalyticsJob.perform_later(url.id, request.remote_ip, request.user_agent, request.referer)
    redirect_to url.original_url, allow_other_host: true
  end
end