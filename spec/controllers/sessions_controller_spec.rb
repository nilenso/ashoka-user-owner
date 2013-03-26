require 'spec_helper'

describe SessionsController do
  context "GET 'new'" do
    it "renders the login page" do
      get :new
      response.should be_ok
      response.should render_template('new')
    end

    it "assigns a blank user" do
      get :new
      assigns(:user).should be_true
      assigns(:applications).should be_true
    end

    it "assigns session for return_to if params is passed" do
      return_to = "http://abc.com"
      get :new, :return_to => return_to
      session[:return_to].should == return_to
    end
  end

  context "POST 'create'" do
    context "user exists" do
      let(:user) { FactoryGirl.create(:user, :status => User::Status::ACTIVE, :organization => FactoryGirl.create(:organization, :status => Organization::Status::ACTIVE)) }
      context "email/password combination is correct" do
        it "logs in the user" do
          post :create, :user => { :email => user.email, :password => user.password}
          response.should redirect_to(root_path)
          session[:user_id].should == user.id
        end

        it "redirects to return to page if user is authorizing from a client app" do
          session[:return_to] = "http://google.com"
          post :create, :user => { :email => user.email, :password => user.password }
          response.should redirect_to("http://google.com")
        end

        it "doesn't allow the user to log in if his organization is not active" do
          user = FactoryGirl.create(:user, :organization => FactoryGirl.create(:organization, :status => Organization::Status::INACTIVE))
          post :create, :user => { :email => user.email, :password => user.password }
          response.should redirect_to deactivated_path
        end

        it "doesn't allow the user to log in if he is not active" do
          user = FactoryGirl.create(:user, :status => User::Status::INACTIVE, :organization => FactoryGirl.create(:organization))
          post :create, :user => { :email => user.email, :password => user.password }
          response.should redirect_to root_path
          flash[:error].should_not be_empty
        end

        it "redirects to the root path if user is super_admin" do
          user = FactoryGirl.create(:super_admin_user, :organization => FactoryGirl.create(:organization), :role => 'super_admin')
          post :create, :user => { :email => user.email, :password => user.password }
          response.should redirect_to root_path
        end

        it "notifies the user with a flash notice that he has signed in" do
          post :create, :user => { :email => user.email, :password => user.password}
          flash[:notice].should_not be_nil
        end

        it "allows case insentive email address" do
          post :create, :user => { :email => user.email.upcase, :password => user.password}
          response.should redirect_to(root_path)
          session[:user_id].should == user.id
        end
      end
    end

    context "user doesn't exist or email/password combination is incorrect" do
      it "redirects to the login page with a flash error" do
        post :create, :user => { :email => "foo@bar.com", :password => "" }
        response.should redirect_to login_path
        flash[:error].should_not be_nil
      end
    end
  end

  context "DELETE 'destroy'" do
    it "logs out the current user and redirects to login page" do
      delete :destroy
      response.should redirect_to(root_path)
      session[:user_id].should be_nil
    end
  end
end
