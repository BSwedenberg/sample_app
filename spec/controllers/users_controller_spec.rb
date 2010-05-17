require 'spec_helper'

describe UsersController do
	integrate_views

	describe "POST 'create'"do
		
		describe "failure" do
			before(:each) do
				@attr = { :name => "", :email => "", :password => "",
						  :password_confirmation => "" }
				@user = Factory.build(:user, @attr)
				User.stub!(:new).and_return(@user)
				@user.should_receive(:save).and_return(false)
			end
			
			it "should have the right title" do
				post :create, :user => @attr
				response.should have_tag("title", /Sign up/i)
			end
			
			it "should render the 'new' page" do
				post :create, :user => @attr
				response.should render_template('new')			
			end
		
		end
		
		describe "success" do
			
			before(:each) do
				@attr = { :name => "Mallory", :email => "email@email.com",
						   :password => "password", :password_confirmation => "password" }
				@user = Factory(:user, @attr)
				User.stub!(:new).and_return(@user)
				@user.should_receive(:save).and_return(true)
			end
			
			it "should redirect to the user show page" do
				post :create, :user => @attr
				response.should redirect_to(user_path(@user))
			end
			
			it "should have a welcome message" do
				post :create, :user => @attr
				flash[:success].should =~ /welcome to the sample app/i
			end

		end
	end
	
    describe "GET 'show'" do
	
		before(:each) do
			@user = Factory(:user)
			# Arrange for User.find(params[:id]) to find the right user.
			User.stub!(:find, @user.id).and_return(@user)
		end
		
		it "should be successful" do
			get :show, :id => @user
			response.should be_success
		end
		
		it "should have the right title" do
			get :show, :id => @user
			response.should have_tag("title", /#{@user.name}/)
		end
		
		it "should include the users name" do
			get :show, :id => @user
			response.should have_tag("h2", /#{@user.name}/)
		end
		
		#it "should have a profile image" do
		#	get :show, :id => @user
		#	response.should have_tag("h2>img", :class => "gravatar")
		#end
  end
  
  describe "GET 'new'" do
	it "should be successful" do
		get :new
		response.should be_success
	end
	
	it "should have the right title" do
		get :new
		response.should have_tag("title", /Sign up/)
	end
  
  end
  
  describe "Get 'edit'" do
	before(:each) do
		@user = Factory(:user)
		test_sign_in(@user)
	end
	
	it "should be successful" do
		get :edit, :id => @user
		response.should be_success
	end
	
	it "should have the right title" do
		get :edit, :id => @user
		response.should have_tag("title", /edit user/i)
	end
  end
  
  describe "GET 'index'" do
	describe "for non-signed-in user" do
		it "should deny access" do
			get :index
			response.should redirect_to(signin_path)
			flash[:notice].should =~ /sign in/i
		end
	end
	
	describe "for signed-in users" do
		before(:each) do
			@user = test_sign_in(Factory(:user))
		end
		
		it "should be successful" do
			get :index
			response.should be_success
		end
		
		it "should get correct page" do
			get :index
			response.should have_tag("title", /all users/i)
		end
		
		it "should have an element for each user" do
			second_user = Factory(:user, :email => "another@example.com")
			third_user =  Factory(:user, :email => "another@example.net")
			get :index
			[@user, second_user, third_user].each do |user|
				response.should have_tag("li", user.name)
			end
		end
	end
  end
end
