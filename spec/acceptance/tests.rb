require_relative "acceptance_helper"

class Tests < Minitest::Spec 
    
    include ::Capybara::DSL
    include ::Capybara::Minitest::Assertions

    def self.test_order
        :alpha 
    end

    before do
        visit '/'
    end

    after do 
        Capybara.reset_sessions!
    end

    it 'login, create groupchat and logout' do

        sleep 1
        find('a', text: 'Login').click
        sleep 1

        within("#login-form") do
            fill_in('username', with: "Tester1")
            fill_in('plaintext', with: "1")
            sleep 1
            click_button 'Login'
        end
        
        _(page).must_have_css('#friends')
        sleep 1
        find('#toggle-menu').click
        sleep 1
        find('a', text: 'New Groupchat').click
        sleep 1

        within("#new-groupchat-form") do
            fill_in('group_name', with: "Test")
            find('#Tester2').click
            find('#Tester3').click
            sleep 1
            click_button 'Start Chat'
            sleep 1
        end

        find('#toggle-menu').click
        sleep 1
        find('a', text: 'Home').click
        sleep 1
        find('a', text: 'Groups').click
        sleep 1
        find('#toggle-menu').click
        sleep 1
        find('a', text: 'Logout').click
        sleep 1


    end

end