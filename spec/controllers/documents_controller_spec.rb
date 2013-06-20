require 'spec_helper'

describe DocumentsController do
  before(:each) { sign_in_as(FactoryGirl.create(:super_admin_user)) }
  context "POST create" do
    context "when creation is successful" do
      it "creates a new terms of service document" do
        tos_file = fixture_file_upload('/documents/placeholder.pdf')
        expect { post :create, :terms_of_service => { :document => tos_file }}.to change { TermsOfService.count }.by(1)
      end

      it "redirects to the root page" do
        tos_file = fixture_file_upload('/documents/placeholder.pdf')
        post :create, :terms_of_service => { :document => tos_file }
        flash[:notice].should be_present
        response.should redirect_to(root_path)
      end
    end

    context "when the creation is unsuccessful" do
      it "doesn't create a new terms of service document" do
        expect { post :create, :terms_of_service => { :document => nil }}.not_to change { TermsOfService.count }
      end

      it "re-renders the new page with errors" do
        post :create, :terms_of_service => { :document => nil }
        flash[:error].should be_present
        response.should render_template(:new)
      end
    end
  end
end
