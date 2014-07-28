class User < ActiveRecord::Base

    has_many :microposts, dependent: :destroy #the option dependent: :destroy arranges for the dependent microposts (those belonging to a given user) to be destroyed when the user is destroyed
    has_many :relationships, foreign_key: "follower_id", dependent: :destroy
     #before_save {self.email = email.downcase} #using before_save callback to ensure email is in downcase format
                                                # before saving to database
    has_many :followed_users, through: :relationships, source: :followed

    has_many :reverse_relationships, foreign_key: "followed_id",
                                        class_name: "Relationship",
                                        dependent: :destroy
    has_many :followers, through: :reverse_relationships, source: :follower

    #can be re-written as
     before_save {email.downcase!}
     before_create :create_remember_token



     validates :name, presence: true, length: { maximum: 50 }

     #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
     # updated version, taking into account emails like foo@bar..com

     VALID_EMAIL_REGEX  = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d-]+)*\.[a-z]+\z/i

     validates :email, presence: true,
                       format: { with: VALID_EMAIL_REGEX },
                       uniqueness: { case_sensitive: false }

     has_secure_password

     validates :password, length: { minimum: 6 }

     def User.new_remember_token
        SecureRandom.urlsafe_base64
     end

     def User.digest(token)
        Digest::SHA1.hexdigest(token.to_s)
     end

     def feed
        Micropost.from_users_followed_by(self)
     end

     def following?(other_user)
        relationships.find_by(followed_id: other_user.id)
     end

     def follow!(other_user)
        relationships.create!(followed_id: other_user.id)
     end

     def unfollow!(other_user)
        relationships.find_by(followed_id: other_user.id).destroy
     end

     private

        def create_remember_token
            self.remember_token = User.digest(User.new_remember_token)
        end

end
