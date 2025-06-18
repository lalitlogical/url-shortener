class RedirectController < ApplicationController
  MAX_ATTEMPTS = 5
  BLOCK_DURATION = 10.seconds

  def show
    url = Rails.cache.fetch("short:#{params[:short_code]}", expires_in: 6.hours) do
      ShortenedUrl.active.find_by(short_code: params[:short_code])
    end

    return render json: { error: 'URL expired or not found' }, status: :not_found if url.nil? || url.expired?

    ip = request.remote_ip
    fail_key = "passcode:fail:#{url.short_code}:#{ip}"

    if url.passcode_digest.present?
      if failed_attempts_exceeded?(fail_key)
        return render json: { error: "Too many failed attempts. Try again later." }, status: :too_many_requests
      end

      input_passcode = params[:passcode]
      if input_passcode.blank? || !url.authenticate_passcode(input_passcode)
        increment_fail_count(fail_key)
        return render json: { error: 'Invalid or missing passcode' }, status: :unauthorized
      end

      reset_fail_count(fail_key)
    end

    AnalyticsJob.perform_later(url.id, request.remote_ip, request.user_agent, request.referer)
    redirect_to url.original_url, allow_other_host: true
  end

  private

  def failed_attempts_exceeded?(key)
    $redis.get(key).to_i >= MAX_ATTEMPTS
  end

  def increment_fail_count(key)
    $redis.multi do
      $redis.incr(key)
      $redis.expire(key, BLOCK_DURATION.to_i)
    end
  end

  def reset_fail_count(key)
    $redis.del(key)
  end
end