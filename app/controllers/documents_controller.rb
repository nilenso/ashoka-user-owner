class DocumentsController < ApplicationController
  authorize_resource :class => false

  def new
    @terms_of_service = TermsOfService.new
  end


  def create
    documents = DocumentCreator.new(params.slice(:terms_of_service, :privacy_policy))

    if documents.errors.all?(&:empty?)
      flash[:notice] = t('documents.create.document_uploaded')
      redirect_to documents_path
    else
      flash[:error] = [t('documents.create.failed_upload')] + documents.errors.map(&:full_messages).flatten
      render :new
    end
  end

  def index
    @terms_of_service = TermsOfService.latest
  end
end
