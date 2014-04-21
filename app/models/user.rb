class User < ActiveRecord::Base

     #before_save {self.email = email.downcase} #using before_save callback to ensure email is in downcase format
                                                # before saving to database

    #can be re-written as
     before_save {email.downcase!}

     validates :name, presence: true, length: { maximum: 50 }

     #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
     # updated version, taking into account emails like foo@bar..com

     VALID_EMAIL_REGEX  = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d-]+)*\.[a-z]+\z/i

     validates :email, presence: true,
                       format: { with: VALID_EMAIL_REGEX },
                       uniqueness: { case_sensitive: false }

     has_secure_password

     validates :password, length: {minimum: 6 }

end
