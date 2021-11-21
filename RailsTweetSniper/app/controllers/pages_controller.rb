class PagesController < ApplicationController
  def home
    @title = "Home"

    if signed_in?
      # @user_id = session[:logged_in_user_id]
      @user_id = current_user.id
    else
      redirect_to signin_path, :notice => "Please sign in"
    end
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

  def twitter_login
    @title = "Twitter Login"
    @zone  = "twitter_login"
  end

end
