class TribesController < ApplicationController
  respond_to :html, :xml, :json


  # GET /tribes
  # GET /tribes.xml
  def index
    @zone = Tribe::ZONE_ID

    logger.debug("##### index - current_user.id = #{current_user.id}")

    if current_user.id.to_s == params[:user_id]
      logger.debug("##### index - Lookup up tribes with user id: #{current_user.id}")
      @tribes = Tribe.where(:user_id => params[:user_id]).sort_by_name
      logger.debug("##### index - tribes.size = #{@tribes.size}")
    else
      logger.warn("##### index - security error - not doing tribe lookup")
      render :text => "Access Error" && return
    end

    respond_with(@tribes)
  end


  def show_tweets
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.find(params[:id])

    unless @tribe.twitter_users
      logger.info("##### TribesController#show_tweets - tribe does not have twitter users - redirecting")
      flash[:notice] = "No twitter users found in tribe '#{@tribe.name}'"
      redirect_to(user_tribes_path(:user_id => current_user.id)) && return
    end

    @twitter_users_array = @tribe.twitter_users.split(",").map{|v| v.strip}
    logger.debug("##### TribesController#show_tweets - @twitter_users_array = #{@twitter_users_array} ")
    @zone = "tribal"
    @user_id = current_user.id   # session[:logged_in_user_id]
    @user = User.find(@user_id)
    @tweets_per_person = 2   # @user.tweet_style.tweets_per_person  # FIXME: populate table on signup
    is_auth = false
    is_auth = true if (session[:twitter] && (session[:twitter][:is_auth] == true))

    logger.debug("##### TribesController#show_tweets - is_auth=#{is_auth}")

    if is_auth == false
      flash[:notice] = "Not yet authorized via Twitter"
      redirect_to(root_path) && return
    end

    credentials_token  = session[:twitter][:cred_token]
    credentials_secret = session[:twitter][:cred_secret]
    logger.debug("##### TribesController#show_tweets - cred token = #{credentials_token}     cred secret = #{credentials_secret}") if Rails.env = "development"

    logger.debug("##### show_tweets - Redis Config - Username=#{REDIS_USERNAME}   SERVER=#{REDIS_SERVER}   PORT=#{REDIS_PORT}")
    if REDIS_SERVER == "localhost" 
      redis_url = "redis://#{REDIS_USERNAME}:#{REDIS_PASSWORD}@#{REDIS_SERVER}:#{REDIS_PORT}"
    else
      redis_url = "redis://#{REDIS_USERNAME}:#{REDIS_PASSWORD}@#{REDIS_SERVER}.redistogo.com:#{REDIS_PORT}"
    end

    if !session[:is_data_in_redis]
      # get data from twitter and store in redis
      logger.debug("##### TribesController#show_tweets - friend tweets NOT found yet, so calling twitter api ...")
      all_friends = Tweets.get_tweets_of_friends(credentials_token, credentials_secret)
      logger.debug("##### TribesController#show_tweets - saving in Redis ...")
      uri = URI.parse(redis_url)
      logger.debug("##### TribesController#show_tweets - uri.host = #{uri.host}     uri.port = #{uri.port} ")
      redis_api = RedisServer.redis_api(uri)
      redis_api.set(@user_id, all_friends.to_s)
      session[:is_data_in_redis] = true

    else
      # get data from redis
      logger.debug("##### TribesController#show_tweets - previous friend tweets found, so NOT calling twitter api")
      uri = URI.parse(redis_url)
      # redis_api = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      redis_api = RedisServer.redis_api(uri)
      logger.debug("##### TribesController#show_tweets - REDIS - Calling redis with @user_id=#{@user_id}")
      friends_in_redis = redis_api.get(@user_id)
      logger.debug("##### TribesController#show_tweets - REDIS - Converting redis data string to array ...")
      all_friends = eval(friends_in_redis)   # convert string to array
    end

    logger.debug("##### TribesController#show_tweets - all_friends = #{all_friends.map{|f| f[:screen_name]}.sort.inspect} ")
    @friends = Tweets.filter_out_non_tribal(all_friends, @twitter_users_array)


    if @friends.blank?
      logger.debug("@friends.size = 0")
    else
      logger.debug("@friends.size = #{@friends.size}")
    end
    logger.debug("DEBUGGING - Friend names: |#{@friends.join(', ')}|")

    logger.debug("##### TribesController#show_tweets - twitter users in tribe = #{@twitter_users_array.inspect}")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tribe }
    end
  end


  # GET /tribes/1
  # GET /tribes/1.xml
  def show
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tribe }
    end
  end


  # GET /tribes/new
  # GET /tribes/new.xml
  def new
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.new
    @current_user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tribe }
    end
  end


  def new_member
    @tribe_id = params[:id]
    @user_id = current_user.id
    @user = User.find(@user_id)
    @tweets_per_person = 2   # @user.tweet_style.tweets_per_person  # FIXME: populate table on signup
    is_auth = false
    is_auth = true if (session[:twitter] && (session[:twitter][:is_auth] == true))

    logger.debug("##### TribesController#new_member - is_auth=#{is_auth}   is_auth.class=#{is_auth.class}")

    if is_auth == false
      logger.info("##### TribesController#new_member - NOT AUTHORIZED yet in twitter, so redirecting to root path")
      redirect_to(root_path, :notice => 'Cannot add members to tribe until authorize with twitter') && return
    end

    # auth via twitter, so ok to continue
    credentials_token  = session[:twitter][:cred_token]
    credentials_secret = session[:twitter][:cred_secret]
    logger.debug("##### UsersController#twitter_text - cred token = #{credentials_token}     cred secret = #{credentials_secret}") if Rails.env = "development"
    @prisoners = {}
    @user.jail_cells.each do |prisoner|
      @prisoners[prisoner.screen_name] = nil
    end
    logger.debug("##### twitter_text - Prisoners = #{@prisoners.inspect}")

    logger.debug("##### twitter_text - Redis Config - Username=#{REDIS_USERNAME}   SERVER=#{REDIS_SERVER}   PORT=#{REDIS_PORT}")
    redis_url = RedisServer.url

    if !session[:is_data_in_redis]
      # get data from twitter and store in redis
      logger.debug("##### UsersController#twitter_text - friend tweets NOT found yet, so calling twitter api ...")
      all_friends = Tweets.get_tweets_of_friends(credentials_token, credentials_secret)
      logger.debug("##### UsersController#twitter_text - saving in Redis ...")
      uri = URI.parse(redis_url)
      logger.debug("##### UsersController#twitter_text - uri.host = #{uri.host}     uri.port = #{uri.port} ")
      redis_api = RedisServer.redis_api(uri)
      redis_api.set(@user_id, all_friends.to_s)
      session[:is_data_in_redis] = true

    else
      # get data from redis
      logger.debug("##### UsersController#twitter_text - previous friends tweets found, so NOT calling twitter api")
      uri = URI.parse(redis_url)
      redis_api = RedisServer.redis_api(uri)
      logger.debug("##### UsersController#twitter_text - REDIS - Calling redis with @user_id=#{@user_id}")
      friends_in_redis = redis_api.get(@user_id)
      logger.debug("##### UsersController#twitter_text - REDIS - Converting redis data string to array ...")
      all_friends = eval(friens_in_redis)   # convert string to array
    end

    @friends = all_friends
    @friends_for_select = @friends.map{ |f| [ "#{f[:name]} (#{f[:screen_name]})", f[:screen_name] ] }
    @friends_for_data_list = @friends.map{|f| "#{f[:screen_name]}" }

    if @friends.blank?
      logger.debug("@friends.size = 0")
    else
      logger.debug("@friends.size = #{@friends.size}")
    end
    logger.debug("DEBUGGING - Friend names: |#{@friends.join(', ')}|")

  end



  def create_members
    if params[:members].blank?
      render :text => "Member not found" and return
    end

    tribe = Tribe.find(params[:tribe_id])
    if params[:html5data].blank?
      all_members = params[:members].join(", ")
    else
      # added alternative HTML5 datalist text box
      all_members = params[:html5data]
    end

    if tribe.update_attribute(:twitter_users, all_members)
        logger.debug("##### TribesController#create_members - updated twitter users")
        redirect_to(user_tribes_path(:user_id => current_user.id), :notice => 'Tribe members were successfully added.') and return
    else
      render(:text => "Something went wrong") && return
    end
      
  end



  # GET /tribes/1/edit
  def edit
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.find(params[:id])
  end


  # POST /tribes
  # POST /tribes.xml
  def create
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.new(tribal_params(params))

    if params[:user_id] != current_user.id.to_s
      # security check - make sure user id in url matches id of current user
      raise "Security Error"
    end

    @tribe.user_id = current_user.id

    respond_to do |format|
      if @tribe.save
        redirect_to(new_member_user_tribe_path(@tribe, :user_id => current_user.id), :notice => 'Tribe created, please add members to your tribe') && return
        # format.html { redirect_to(user_tribe_path(@tribe, :user_id => current_user.id), :notice => 'Tribe was successfully created.') }
        # format.xml  { render :xml => @tribe, :status => :created, :location => @tribe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tribe.errors, :status => :unprocessable_entity }
      end
    end

  end

  # PUT /tribes/1
  # PUT /tribes/1.xml
  def update
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.find(params[:id])

    respond_to do |format|
      if @tribe.update(tribal_params params)    # params[:tribe])
        # format.html { redirect_to(@tribe, :notice => 'Tribe was successfully updated.') }
        format.html { redirect_to(user_tribes_path(:id => current_user.id), :notice => 'Tribe was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tribe.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tribes/1
  # DELETE /tribes/1.xml
  def destroy
    @zone = Tribe::ZONE_ID
    @tribe = Tribe.find_by id: params[:id]

    flash[:notice] = "Tribe Obliterated!"

    unless @tribe
      # calls destroy twice sometimes, so return early if called a second time
      redirect_to(user_tribes_path(:user_id => current_user.id)) && return
    end

    user = @tribe.user

    if user.id.to_s != current_user.id.to_s
      # security check - make sure user id in url matches id of current user
      raise "Security Error"
    end

    @tribe.destroy

    respond_to do |format|
      format.html { redirect_to(user_tribes_url(user)) }
      format.xml  { head :ok }
    end
  end


  private
    def tribal_params(params)
      params.require(:tribe).permit(:name, :description)
    end
end


