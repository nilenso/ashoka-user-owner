class OrganizationDecorator < Draper::Decorator
  delegate_all

  def label_for_terms_of_service
    (I18n.t("organizations.new.accept_legal_prefix") + link_to_terms_of_service).html_safe
  end

  def link_to_terms_of_service
    document_url = TermsOfService.any? ? TermsOfService.latest.document_url : '#'
    h.link_to(I18n.t("organizations.new.terms_of_service"), document_url, :class => "organization-legal-item-label-link", :target => '_blank')
  end

  def label_for_privacy_policy
    (I18n.t("organizations.new.accept_legal_prefix") + link_to_privacy_policy).html_safe
  end

  def link_to_privacy_policy
    document_url = PrivacyPolicy.any? ? PrivacyPolicy.latest.document_url : '#'
    h.link_to(I18n.t("organizations.new.privacy_policy"), document_url, :class => "organization-legal-item-label-link", :target => '_blank')
  end
end
