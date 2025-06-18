class AnalyticsJob < ApplicationJob
  queue_as :default

  def perform(url_id, ip, agent, referer)
    Click.create!(
      shortened_url_id: url_id,
      ip_address: ip,
      user_agent: agent,
      referer: referer
    )
    ShortenedUrl.increment_counter(:click_count, url_id)
  end
end