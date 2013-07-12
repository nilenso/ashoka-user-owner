class LogoUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/user_service/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png)
  end
end
