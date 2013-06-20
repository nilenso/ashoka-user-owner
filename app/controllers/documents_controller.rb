class DocumentsController < ApplicationController
  authorize_resource :class => false

  def new
    @terms_of_service = TermsOfService.new
  end


  def create
    tos = TermsOfService.new(params[:terms_of_service])
    if tos.save
      flash[:notice] = t('.document_uploaded')
      redirect_to documents_path
    else
      flash[:error] = t('.failed_upload')
      @terms_of_service = tos
      render :new
    end
  end

  def index
    @terms_of_service = TermsOfService.latest
  end
end
