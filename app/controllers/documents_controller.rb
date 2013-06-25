class DocumentsController < ApplicationController
  authorize_resource :class => false

  def new
    @terms_of_service = TermsOfService.new
    @privacy_policy = PrivacyPolicy.new
  end


  def create
    documents = DocumentPresenter.new(params[:documents])

    if documents.save
      flash[:notice] = t('documents.create.document_uploaded')
      redirect_to documents_path
    else
      flash[:error] = [t('documents.create.failed_upload')] + documents.errors.full_messages.flatten
      render :new
    end
  end

  def index
    @terms_of_service = TermsOfService.latest
    @privacy_policy = PrivacyPolicy.latest
  end
end
