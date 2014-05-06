require 'spec_helper'

describe "MicropostPages" do

    subject { page }

    let(:user) { FactoryGirl.create(:user) }

    before { sign_in user }

    describe "micropost pagination" do

        it "should paginate the feed" do

            50.times {FactoryGirl.create(:micropost, user: user)}
            visit root_path
            page.should have_content("Micropost Feed")
            page.should have_selector('div.pagination')

        end

        it "should list each micropost" do
            Micropost.paginate(page: 1).each do |item|
                # expect(page).to have_selector('li', text: item.content)
                page.should have_selector('li##{item.id}', text: item.content)
            end
        end

    end


    describe "micropost creation" do
        before { visit root_path }

        describe "with invalid information" do
            it "should not create a micropost" do
                expect { click_button "Post"}.not_to change(Micropost, :count)
            end

            describe "error messages" do
                before { click_button "Post" }
                it { should have_content('error') }
            end # end of "error messages"

        end # end of "with invalid information"

        describe "with valid information" do

            before { fill_in 'micropost_content', with: "Lorem ipsum" }

            it "should create a micropost" do
                expect { click_button "Post"}.to change(Micropost, :count).by(1)
            end
        end # end of with valid information

    end # end of "micropost creation"

    describe "micropost destruction" do
        before { FactoryGirl.create(:micropost, user: user) }

        describe "as correct user" do
            before { visit root_path }

            it "should delete a micropost" do
                expect { click_link "delete" }.to change(Micropost, :count).by(-1)
            end

        end # end of as correct user
    end # end of micropost destruction
#end # end of test
end
