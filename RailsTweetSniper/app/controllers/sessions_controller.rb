class SessionsController < ApplicationController

  def new
    @title = "Sign in"
  end


  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    logger.info("##### SessionsController#create - user = #{user}")

    if user.nil?
      logger.info("##### SessionsController#create - user is nil - probably bad password or username")
      flash.now[:error] = "Invalid email/password combination"
      @title = "Sign in"
      render 'new'
    else
      logger.info("##### SessionsController#create - user exists - signing in user")
      sign_in user
      session[:is_registered] = true
      redirect_back_or user
    end

  end


  def destroy
    sign_out
    # redirect_to root_path
    redirect_to goodbye_path
  end


  def goodbye
  end

end


