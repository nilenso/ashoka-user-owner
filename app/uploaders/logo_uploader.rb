class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  version :thumb do
    process :resize_to_fit => [100, 100]
  end

  def store_dir
    "uploads/user_service/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png)
  end
end
