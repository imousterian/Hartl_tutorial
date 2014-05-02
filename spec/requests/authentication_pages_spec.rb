require 'spec_helper'

describe "AuthenticationPages" do

    subject {page}

    describe "signin page" do
        before { visit signin_path }

        it { should have_content('Sign in') }
        it { should have_title('Sign in') }

    end # end of "signin page"

    describe "signin" do

        before { visit signin_path }

        describe "with invalid information" do
            before { click_button "Sign in" }

            it { should have_title("Sign in")}
            it { should have_error_message('Invalid')}
            # it { should have_selector('div.alert.alert-error')}

            describe "after visiting another page" do
                before { click_link "Home" }
                it { should_not have_selector('div.alert.alert-error') }
            end
        end # end of "with invalid information"

        describe "with valid information" do
            let(:user) { FactoryGirl.create(:user) }
            before { sign_in user }


            it {should have_title(user.name)}

            it { should have_link('Users', href: users_path)}
            it {should have_link('Profile', href: user_path(user))}
            it {should have_link('Settings', href: edit_user_path(user))}
            it {should have_link('Sign out', href: signout_path)}
            it {should_not have_link('Sign in', href: signin_path)}

            describe "followed by signout" do
                before { click_link "Sign out" }
                it { should have_link('Sign in')}
            end

        end

        describe "for signed in users" do

            let(:user) { FactoryGirl.create(:user)}
            let(:new_user) { FactoryGirl.attributes_for(:user)}

            before { sign_in user, no_capybara: true }

            describe "using a 'new' action" do
                before { get new_user_path }
                specify { response.should redirect_to(root_path)}
            end

            describe "using a 'create' action" do
                before { post users_path (new_user) }
                specify { response.should redirect_to(root_path)}
            end

        end # end of "for signed in users"

    end # end of "signin"

    describe "authorization" do



        describe "for non-signed-in users" do

            let(:user) { FactoryGirl.create(:user) }

            describe "it should not have a profile and settings page" do
                before {visit user_path(user)}
                it {should have_link('Sign in', href: signin_path)}
                it {should_not have_link('Profile')}
                it {should_not have_link('Settings')}
            end

            describe "when attempting to visit a protected page" do
                before do
                    visit edit_user_path(user)
                    fill_in "Email", with: user.email
                    fill_in "Password", with: user.password
                    click_button "Sign in"
                end

                describe "after signing in" do
                    it "should render the desired protected page" do
                        expect(page).to have_title('Edit user')
                    end

                    describe "when signing in again" do
                        before do
                            click_link "Sign out"
                            visit signin_path
                            fill_in "Email", with: user.email
                            fill_in "Password", with: user.password
                            click_button "Sign in"
                        end

                        it "should render the default (profile) page" do
                            expect(page).to have_title(user.name)
                        end
                    end # end of "when signing in again"
                end
            end # end of "when attempting to visit a protected page"

            describe "in the Users controller" do
                describe "visiting the edit page" do
                    before { visit edit_user_path(user) }
                    it { should have_title('Sign in') }
                end

                describe "submitting to the update action" do
                    before { patch user_path(user) }
                    specify { expect(response).to redirect_to(signin_path) }
                end

                describe "visiting the user index" do
                    before { visit users_path }
                    it { should have_title('Sign in')}
                end
            end # end of "in the Users controller"

        end # end as "for non-signed-in users"

        describe "as wrong user" do
            let (:user) { FactoryGirl.create(:user) }
            let (:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com")}
            before { sign_in user, no_capybara: true }

            describe "submitting a GET request to the Users#edit action" do
                before { get edit_user_path(wrong_user)}
                specify { expect(response.body).not_to match(full_title('Edit user'))}
                specify { expect(response).to redirect_to(root_url)}
            end

            describe "submitting a PATCH request to the Users#update action" do
                before { patch user_path(wrong_user)}
                specify { expect(response).to redirect_to(root_url)}
            end
        end # end of "as wrong user"

        describe "as non-admin user" do
            let (:user) {FactoryGirl.create(:user)}
            let(:non_admin_md)  {FactoryGirl.create(:user)}

            before { sign_in non_admin_md, no_capybara: true}

            describe "submitting a DELETE request to the Users#destroy action" do
                before { delete user_path(user)}
                specify { expect(response).to redirect_to(root_url)}
            end
        end # end of "as non-admin user"

        describe "as admin user" do
            let(:admin_md) { FactoryGirl.create(:admin_md)}
            before { sign_in admin_md}

            it "cannot delete admin user by submitting DELETE request to Users#destroy action" do
                expect { delete user_path(admin_md)  }.not_to change(User, :count).by(-1)
            end
        end # end of "as admin user"

    end # end of "authorization"

end # end of "authorizationpages"
