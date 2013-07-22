module AssetsHelper
  def asset_url(asset)
    URI::join(ENV["SURVEY_WEB_HOST"], ActionController::Base.helpers.asset_path(asset)).to_s
  end
end