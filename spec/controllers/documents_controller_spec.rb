require 'spec_helper'

describe DocumentsController do
  before(:each) { sign_in_as(FactoryGirl.create(:super_admin_user)) }

  context "GET 'new'" do
    it "assigns a terms of service object" do
      get :new
      assigns(:terms_of_service).should be_a TermsOfService
    end
  end

  context "POST create" do
    context "when creation is successful" do
      it "creates a new terms of service document" do
        tos_file = fixture_file_upload('/documents/placeholder.pdf')
        expect { post :create, :terms_of_service => { :document => tos_file }}.to change { TermsOfService.count }.by(1)
      end

      it "redirects to the index page" do
        tos_file = fixture_file_upload('/documents/placeholder.pdf')
        post :create, :terms_of_service => { :document => tos_file }
        flash[:notice].should be_present
        response.should redirect_to(documents_path)
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

      it "assigns a terms of service object" do
        post :create, :terms_of_service => { :document => nil }
        assigns(:terms_of_service).should be_a TermsOfService
      end
    end
  end

  context "GET 'index'" do
    it "assigns the newest terms of service document" do
      new_terms_of_service = Timecop.freeze(2.days.ago) { FactoryGirl.create(:terms_of_service) }
      old_terms_of_service = Timecop.freeze(10.days.ago) { FactoryGirl.create(:terms_of_service) }
      get :index
      assigns(:terms_of_service).should == new_terms_of_service
    end
  end
end
