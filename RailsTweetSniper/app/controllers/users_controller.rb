require "twitter"

class UsersController < ApplicationController
  before_action :authenticate, :only => [:index, :edit, :update]
  before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user,   :only => :destroy
  rescue_from Twitter::Error::TooManyRequests, with: :twitter_requests_exceeded
  rescue_from Redis::CannotConnectError, with: :redis_connection_problem

  def destroy
    # User.find(params[:id]).destroy
    # flash[:success] = "User destroyed."
    # redirect_to users_path
  end

  def index
    # @title = "All users"
    # @users = User.paginate(:page => params[:page])
  end

  def show
    @user = current_user
    @tweets_per_person = 3
    # session[:logged_in_user_id] = params[:id]
    @title = @user.name

    if @user.tweet_style
      @tweets_per_person = @user.tweet_style.tweets_per_person
    end
  end

  def new
    @user = User.new
    @title = "Sign up"
  end


  def create
    @user = User.new(user_params)

    if @user.save
      sign_in @user
      flash[:success] = "Account created!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end


  def edit
    @title = "Edit user"
  end


  def update
    logger.debug("##### UsersController#update - Starting ...")
    @user = User.find(params[:id])

    if @user.update(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end


  ##### Non-RESTful Customer Actions #####


  def snipe_friend
    @user_id = current_user.id
    JailCell.create!(:user_id => @user_id, :screen_name => params[:sname])

    if params[:zone] && params[:zone] == "text"
      logger.debug("##### UsersController#snipe_friend - zone = 'text' ")
      redirect_to :action => :twitter_text, :id => @user_id
    else
      logger.debug("##### UsersController#snipe_friend - zone NOT = 'text' ")
      redirect_to :action => :twitter_democracy, :id => @user_id
    end
  end



  # like twitter_democracy (Democracy Zone), without images, e.g. user pictures
  def twitter_text
    @zone = "text"
    @user_id = current_user.id
    @user = User.find(@user_id)
    @tweets_per_person = 2   # @user.tweet_style.tweets_per_person  # FIXME: populate table on signup
    is_auth = false
    is_auth = true if (session[:twitter] && (session[:twitter][:is_auth] == true))

    logger.debug("##### UsersController#twitter_text - is_auth=#{is_auth}")

    redirect_to(root_path) if is_auth == false

    if is_auth
      credentials_token  = session[:twitter][:cred_token]
      credentials_secret = session[:twitter][:cred_secret]
      logger.debug("##### UsersController#twitter_text - cred token = #{credentials_token}     cred secret = #{credentials_secret}") if Rails.env = "development"
      @prisoners = {}
      # @prisoners = @user.jail_cells.map(&:screen_name)
      @user.jail_cells.each do |prisoner|
        @prisoners[prisoner.screen_name] = nil
      end
      logger.debug("##### twitter_text - Prisoners = #{@prisoners.inspect}")

      logger.debug("##### twitter_text - Redis Config - Username=#{REDIS_USERNAME}   SERVER=#{REDIS_SERVER}   PORT=#{REDIS_PORT}")

      redis_url = RedisServer.url
      logger.debug("##### twitter_text - redis_url = #{redis_url}")


      if !session[:is_data_in_redis]
        # get data from twitter and store in redis
        logger.debug("##### UsersController#twitter_text - friend tweets NOT found yet, so calling twitter api ...")
        all_friends = Tweets.get_tweets_of_friends(credentials_token, credentials_secret, session)
        logger.debug("##### UsersController#twitter_text - saving in Redis ...")
        uri = URI.parse(redis_url)
        logger.debug("##### UsersController#twitter_text - uri.host = #{uri.host}     uri.port = #{uri.port} ")
        redis_api = RedisServer.redis_api(uri)
        redis_api.set(@user_id, all_friends.to_s)
        session[:is_data_in_redis] = true

      else
        # get data from redis
        logger.debug("##### UsersController#twitter_text - previous friend tweets found, so NOT calling twitter api")
        uri = URI.parse(redis_url)
        logger.debug("##### UsersController#twitter_text - uri.password = #{uri.password}")
        redis_api = RedisServer.redis_api(uri)
        logger.debug("##### UsersController#twitter_text - REDIS - Calling redis with @user_id=#{@user_id}")
        friends_in_redis = redis_api.get(@user_id)
        all_friends = eval(friends_in_redis)   # convert string to array
        logger.debug("##### UsersController#twitter_text - first friend after using eval to convert string to array: #{all_friends.first}")
        logger.debug("##### UsersController#twitter_text - first friend after using eval to convert string to array - # texts: #{all_friends.first[:most_recent_texts].size}")
        logger.debug("##### UsersController#twitter_text - first friend after using eval to convert string to array - keys: #{all_friends.first.keys}")
      end


      @friends = Tweets.filter_out_prisoners(all_friends, @prisoners)
      @prisoner_pictures = Tweets.prisoner_picture_links(all_friends, @prisoners)


      if @friends.blank?
        logger.debug("@friends.size = 0")
      else
        logger.debug("@friends.size = #{@friends.size}")
      end
      # logger.debug("DEBUGGING - Friend names: |#{@friends.join(', ')}|")

    else
      flash[:notice] = twitter_auth_message
      logger.error("##### UsersController#twitter_text - ERROR - Not authorized by Twitter")
    end

  end



  def twitter_democracy
    @zone = "democracy"
    @user_id = current_user.id   # session[:logged_in_user_id]
    @user = User.find(@user_id)
    logger.debug("##### twitter_democracy - @user=#{@user.inspect}")
    @tweets_per_person = 3
    @tweets_per_person = @user.tweet_style.tweets_per_person if @user.tweet_style
    is_auth = false
    is_auth = true if (session[:twitter] && (session[:twitter][:is_auth] == true))

    logger.debug("##### UsersController#twitter_democracy - is_auth=#{is_auth}")

    redirect_to(root_path) if is_auth == false

    if is_auth
      credentials_token  = session[:twitter][:cred_token]
      credentials_secret = session[:twitter][:cred_secret]
      logger.debug("##### UsersController#twitter_democracy - cred token = #{credentials_token}     cred secret = #{credentials_secret}") if Rails.env = "development"
      @prisoners = {}
      # @prisoners = @user.jail_cells.map(&:screen_name)
      @user.jail_cells.each do |prisoner|
        @prisoners[prisoner.screen_name] = nil
      end
      logger.debug("##### UsersController#twitter_democracy - Prisoners = #{@prisoners.inspect}")

      logger.debug("##### UsersController#twitter_democracy - Redis Config - Username=#{REDIS_USERNAME}   SERVER=#{REDIS_SERVER}   PORT=#{REDIS_PORT}")
      redis_url = RedisServer.url
      redis_api = nil

      if !session[:is_data_in_redis]
        # get data from twitter and store in redis
        logger.debug("##### UsersController#twitter_democracy - friend tweets NOT found yet, so calling twitter api ...")
        all_friends = Tweets.get_tweets_of_friends(credentials_token, credentials_secret, session)
        logger.debug("##### UsersController#twitter_democracy - saving in Redis ...")
        uri = URI.parse(redis_url)
        logger.debug("##### UsersController#twitter_democracy - uri.host = #{uri.host}     uri.port = #{uri.port} ")
        redis_api = RedisServer.redis_api(uri)

        redis_api.set(@user_id, all_friends.to_s)
        session[:is_data_in_redis] = true

      else
        # get data from redis
        logger.debug("##### UsersController#twitter_democracy - previous friend tweets found, so NOT calling twitter api")
        uri = URI.parse(redis_url)
        redis_api = RedisServer.redis_api(uri)
        logger.debug("##### UsersController#twitter_democracy - REDIS - Calling redis with @user_id=#{@user_id}")
        friends_in_redis = redis_api.get(@user_id)
        logger.debug("##### UsersController#twitter_democracy - REDIS - Converting redis data string to array for value: #{friends_in_redis.slice(0,300)} ...")
        all_friends = eval(friends_in_redis)   # convert string to array
      end


      @friends = Tweets.filter_out_prisoners(all_friends, @prisoners)
      @prisoner_pictures = Tweets.prisoner_picture_links(all_friends, @prisoners)


      if @friends.blank?
        logger.debug("@friends.size = 0")
      else
        logger.debug("@friends.size = #{@friends.size}")
      end
      # logger.debug("DEBUGGING - Friend names: |#{@friends.join(', ')}|")

    else
      flash[:notice] = twitter_auth_message
      logger.error("##### UsersController#twitter_democracy - ERROR - Not authorized by Twitter")
    end

    # render :text => "Hello from twitter democracy"
  end


  def twitter_login
    # TODO: move much of this to a non-table Twitter model
    logger.info("##### twitter_login - Starting ...")
    key = Rails.application.secrets.twitter_key
    secret = Rails.application.secrets.twitter_secret
    logger.debug("##### twitter_login - TWITTER_KEY = #{key}     TWITTER_SECRET=#{secret}")
    logger.debug("##### twitter_login - request=#{request.inspect}")
    auth = request.env["omniauth.auth"]
    logger.debug("##### twitter_login - auth=#{auth.inspect}")
    logger.debug("##### twitter_login - auth.keys=#{auth.keys}")
    logger.debug("##### twitter_login - auth[extra].keys=#{auth['extra'].keys}")
    logger.debug("##### twitter_login - auth[extra][raw_info].keys=#{auth['extra']['raw_info'].keys}")
    twitter_name   = auth["extra"]["raw_info"]["name"]
    twitter_token  = auth["credentials"]["token"]
    twitter_secret = auth["credentials"]["secret"]
    session[:twitter] = {:user_name => twitter_name, :cred_token => twitter_token, :cred_secret => twitter_secret}
    if !twitter_token.blank?
      session[:twitter][:is_auth] = true
    else
      session[:twitter][:is_auth] = false
    end
    logger.debug("token = #{twitter_token}     secret = #{secret}")
    # logger.debug auth.to_yaml
    logger.debug session.inspect
    # redirect_to user_twitter_democracy_path(session[:logged_in_user_id])
    redirect_to :action => 'twitter_democracy', :id => current_user.id   # session[:logged_in_user_id]
    # render :text => "Twitter user: #{twitter_name}"
  end


  def edit_tweet_count
    # if params[:id] != session[:logged_in_user_id]
    if params[:id] != current_user.id.to_s
      render :text => "Authentication error" && return
    end

    # @user = User.find(session[:logged_in_user_id])
    @user = User.find(current_user.id)
    @tweet_style = @user.tweet_style
    @tweet_style ||= TweetStyle::DEFAULT_ZONE
    logger.debug("##### edit_tweet_count - tweet-style = #{@tweet_style} ")
    # render :text => "Need to show select tag of numbers 1..20" # FIXME
  end


  def update_tweet_count
    logger.debug("##### update_tweet_count - Starting - Params - params[:id] = #{params[:id]}")
    logger.debug("##### update_tweet_count - session[:logged_in_user_id] = #{session[:logged_in_user_id]}")

    if params[:id] != session[:logged_in_user_id].to_s
      render(:text => "Authentication error") && return
    end
    # @user = User.find(session[:logged_in_user_id]) 
    @user = User.find(current_user.id)

    if @user.tweet_style
      @tweet_style = @user.tweet_style
    else
      @user.tweet_style = TweetStyle.new
      @user.tweet_style.save!
      @tweet_style = @user.tweet_style
    end

    if params['DEMOCRACY']
      new_tweets_per_person params['DEMOCRACY']['tweets_per_person']
    else
      new_tweets_per_person = params['tweet_style']['tweets_per_person']
    end

    if @tweet_style.update_attributes(:tweets_per_person => new_tweets_per_person.to_i)
      # render :text => "Save OK" && return
      logger.debug("##### update_tweet_count - session[:logged_in_user_id] = #{session[:logged_in_user_id]}")
      redirect_to(twitter_democracy_user_path(session[:logged_in_user_id]), :notice => "Successfully changed tweet count")   # Rails 3 style flash
    else
      render :text => "Save Not OK" && return
    end
  end

  private

    def tweet_style_params
      params.require(:tweet_style).permit(:tweets_per_person, :id)
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def authenticate
      deny_access unless signed_in?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def twitter_auth_message
      "Not yet authorized via twitter - please see 'Twitter Login' tab"
    end

    def twitter_requests_exceeded
      logger.error "Twitter Requests Exceeded"
      redirect_to tweets_index_url, notice: 'Too Many Twitter Lookups'
    end

    def redis_connection_problem
      logger.error "Redis Connection Problem"
      redirect_to tweets_index_url, notice: 'Too Many Twitter Lookups'
    end
end

