class DocumentCreator
  attr_reader :terms_of_service, :privacy_policy

  def initialize(params)
    ActiveRecord::Base.transaction do
      if params[:terms_of_service].present?
        @terms_of_service = TermsOfService.new(params[:terms_of_service])
        @terms_of_service.save || rollback
      end

      if params[:privacy_policy].present?
        @privacy_policy = PrivacyPolicy.create(params[:privacy_policy])
        @privacy_policy.save || rollback
      end
    end
  end

  def errors
    [terms_of_service, privacy_policy].compact.map(&:errors)
  end

  private

  def rollback
    raise ActiveRecord::Rollback
  end
end
