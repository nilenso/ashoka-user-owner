module AssetsHelper
  def asset_url(asset)
    URI::join(ENV["USER_OWNER_HOST"], ActionController::Base.helpers.asset_path(asset)).to_s
  end
end