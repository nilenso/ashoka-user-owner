class DocumentsController < ApplicationController
  authorize_resource :class => false

  def create
    tos = TermsOfService.new(params[:terms_of_service])
    if tos.save
      flash[:notice] = t('.document_uploaded')
      redirect_to root_path
    else
      flash[:error] = t('.failed_upload')
      render :new
    end
  end
end
