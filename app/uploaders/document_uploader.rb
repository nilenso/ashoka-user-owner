# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/user_service/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(pdf)
  end
end
