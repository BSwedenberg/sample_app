
# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
	user.name		"Mallory"
	user.email		"malpal@email.com"
	user.password	"wordpass"
	user.password_confirmation	"wordpass"
end