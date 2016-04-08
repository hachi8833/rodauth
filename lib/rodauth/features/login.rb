module Rodauth
  Login = Feature.define(:login) do
    notice_flash "You have been logged in"
    error_flash "There was an error logging in"
    view 'login', 'Login'
    after
    after 'login_failure'
    before
    before 'login_attempt'
    additional_form_tags
    button 'Login'
    redirect

    auth_value_method :login_form_footer, ''

    route do |r|
      check_already_logged_in
      before_login_route

      r.get do
        login_view
      end

      r.post do
        clear_session

        catch_error do
          unless account_from_login(param(login_param))
            throw_error(:login, no_matching_login_message)
          end

          before_login_attempt

          unless open_account?
            throw_error(:login, unverified_account_message)
          end

          unless password_match?(param(password_param))
            after_login_failure
            throw_error(:password, invalid_password_message)
          end

          transaction do
            before_login
            update_session
            after_login
          end
          set_notice_flash login_notice_flash
          redirect login_redirect
        end

        set_error_flash login_error_flash
        login_view
      end
    end

    attr_reader :login_form_header
  end
end
