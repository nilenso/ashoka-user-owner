class DocumentPresenter
  def initialize(params)
    @terms_of_service_attributes = params[:terms_of_service]
    @privacy_policy_attributes = params[:privacy_policy]
  end

  def save
    ActiveRecord::Base.transaction do
      if @terms_of_service_attributes.present?
        @terms_of_service = TermsOfService.new(@terms_of_service_attributes)
        if @terms_of_service.save
          OrganizationMailer.delay.notify_cso_admins_of_change_in_terms_of_service
        else
          errors.add(:terms_of_service, @terms_of_service.errors.full_messages.join)
        end
      end

      if @privacy_policy_attributes.present?
        @privacy_policy = PrivacyPolicy.new(@privacy_policy_attributes)
        @privacy_policy.save || errors.add(:privacy_policy, @privacy_policy.errors.full_messages.join)
      end

      if errors.present?
        rollback
      else
        true
      end
    end
  end

  def self.human_attribute_name(attribute_key_name, options = {})
    attribute_key_name.to_s.humanize
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  private

  def rollback
    raise ActiveRecord::Rollback
  end
end
