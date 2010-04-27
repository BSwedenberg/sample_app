require 'spec_helper'

describe SessionsController do
	integrate_views
	
	describe "Get 'new'" do
		it "should be successful" do
			get :new
			response.should be_success
		end
		
		it "should have the right title" do
			get :new
			response.should have_tag("title", /Sign in/)
		end
	end
	
	describe "POST 'create'" do
	
		describe "invalid 'signin'" do
		
			before(:each) do
				@attr = { :email => "malpal@email.com", :password => "wordpass" }
				User.should_receive(:authenticate).
					with(@attr[:email], @attr[:password]).
					and_return(nil)
			end
			
			it "should re-render the new page" do
				post :create, :session => @attr
				response.should render_template('new')
			end
			
			it "should have the right title" do
				post :create, :session => @attr
				response.should have_tag("title", /Sign in/)
			end
		end
		
		describe "with valid email and password" do
			before(:each) do
				@user = Factory(:user)
				@attr = { :email => @user.email, :password => @user.password }
				User.should_receive(:authenticate).
					with(@user.email, @user.password).
					and_return(@user)
			end
			
			it "should sign the user in" do
				post :create, :session => @attr
				controller.current_user.should == @user
				controller.should be_signed_in
			end
			
			it "redirect to the user page" do
				post :create, :session => @user
				redirect_to user_path(@user)
			end
		end
	end
	
	describe "Delete 'destroy'" do
		it "should sign a user out" do
			test_sign_in(Factory(:user))
			controller.should be_signed_in
			delete :destroy
			controller.should_not be_signed_in
			response.should redirect_to(root_path)
		end
	end
end
