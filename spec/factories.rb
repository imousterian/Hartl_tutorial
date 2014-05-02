# FactoryGirl.define do

#   factory :user do
#     name "Fidel Awesome"
#     email "fidel@awesome.com"
#     password "foobar"
#     password_confirmation "foobar"

#   end

# end

FactoryGirl.define do

    factory :user do
        sequence(:name) { |n| "Person #{n}"}
        sequence(:email) { |n| "person_#{n}@example.com" }
        password "foobar"
        password_confirmation "foobar"

        factory :admin_md do
            admin_md true
        end
    end
end











