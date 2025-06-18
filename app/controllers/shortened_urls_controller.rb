class ShortenedUrlsController < ApplicationController
  def create
    url = ShortenedUrl.new(url_params)
    if url.save
      render json: { short_url: request.base_url + '/' + url.short_code, passcode_protected: url.passcode_digest.present? }, status: :created
    else
      render json: { errors: url.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    render json: ShortenedUrl.order(created_at: :desc)
  end

  def show
    url = ShortenedUrl.find(params[:id])
    render json: url
  end

  private

  def url_params
    params.require(:shortened_url).permit(:original_url, :expiration, :passcode)
  end
end