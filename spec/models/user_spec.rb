require 'spec_helper'

describe User do
  before(:each) do
    @valid_attributes = {:name => "Example User",
						 :email => "email@email.com",
						 :password => "Password",
						 :password_confirmation => "Password"
						 }
	@attr = {:name => "Brian",
			 :email => "fake@fake.com",
			 :password => "wordpass",
			 :password_confirmation => "wordpass"
			 }
  end
  
  
  it "should create a valid instance, given valid attributes" do
	User.create!(@valid_attributes)
  end
  
  it "should require a name" do
	no_name_user = User.new(@valid_attributes.merge(:name => ""))
	no_name_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@valid_attributes.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
	addresses.each do |address|
		valid_email_user = User.new(@valid_attributes.merge(:email => address))
		valid_email_user.should be_valid
	end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@valid_attributes.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@valid_attributes)
    user_with_duplicate_email = User.new(@valid_attributes)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject duplicate email up to case" do
	upcase_email = @valid_attributes[:email].upcase
	User.create!(@valid_attributes.merge(:email => upcase_email))
	user_with_duplicate_email = User.new(@valid_attributes)
	user_with_duplicate_email.should_not be_valid
  end
  
  describe "password validations" do
  it "should require a password" do
	User.new(@attr.merge(:password => "", :password_confirmation => ""))
    should_not be_valid
  end
	
  it "should require a matching password confirmation" do
	User.new(@attr.merge(:password => "invalid"))
	should_not be_valid
  end
  
  it "should reject short passwords" do
	short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
   end

   it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
   end
   end
   
    describe "password encryption" do
		before(:each) do
			@user=User.create!(@attr)
		end
		
		it "should have an encrypted password attribute" do
			@user.should respond_to(:encrypted_password)
		end
		
		it "should set encrypted password" do
			@user.encrypted_password.should_not be_blank
		end
		
		describe "has_password? method" do
			
			it "should be true if the passwords match" do
				@user.has_password?(@attr[:password]).should be_true
			end
			
			it "should be false if the passwords don't match" do
				@user.has_password?("invalid").should be_false
			end
		end
		
		describe "authenticate password" do
		
			it "should return nil on email/password mismatch" do
				wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
				wrong_password_user.should be_nil
			end
			
			it "should return nil for email adress with no user" do
				wrong_email_user = User.authenticate("wrong@wong.edu", "password")
				wrong_email_user.should be_nil
			end
					
		end
    end
	
	describe "remember me" do
		before(:each) do
			@user = User.create!(@attr)
		end
		
		it "should have a remember_me method" do
			@user.should respond_to(:remember_me!)
		end
		
		it "should have a remember_token" do
			@user.should respond_to(:remember_token)
		end
		
		it "should set the remember_token" do
			@user.remember_me!
			@user.remember_token.should_not be_nil
		end
	end
	
	describe "admin attribute" do
		before(:each)do
			@user = User.create!(@attr)
		end
		
		it "should respond to admin" do
			@user.should respond_to(:admin)
		end
		
		it "should not be an admin by default" do
			@user.should_not be_admin
		end
		
		it "should be convertable to an admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
		
	end
	
	describe "Delete 'destroy'" do
		
		before(:each) do
			@user = Factory(:user)
		end
		
		describe "as a non-signed-in user" do
			it "should deny access" do
				delete :destroy, :id => @user
				response.should redirect_to(signin_path)
			end
		end
		
		describe "as a non-admin user" do
			it "should protect the page" do
				test_sign_in(@user)
				delete :destroy, :id => @user
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an admin user" do
			
			before(:each) do
				admin = Factory(:user, :email => "admin@email.com", :admin => true)
				test_sign_in(admin)
				User.should_receive(:find).with(@user).and_return(@user)
				@user.should_recieve(:destroy).and_return(@user)
			end
			
			it "should destroy the user" do
				delete :destroy, :id => @user
				response.should redirect_to(users_path)
			end
			
		end
		
	end
end
