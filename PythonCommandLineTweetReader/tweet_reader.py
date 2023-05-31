
import os
import platform
import re
import settings_mine
import sys
import tweepy


IS_DEBUGGING = False
user = None
current_username = None


def show_followers_count(usr):
  print('Followers count:' + str(usr.followers_count))


def show_description(usr):
  print('User Description: ' + usr.description)


def show_friends(usr, twitterApi):
  friends = []
  global current_username
  global user
  # cursor = tweepy.Cursor(twitterApi.friends, screen_name=usr.screen_name, count=200)
  cursor = tweepy.Cursor(twitterApi.get_friends, screen_name=usr.screen_name, count=200)
  for friend in cursor.items(200):
      friends.append(friend.screen_name)

  friends = sorted(friends, key=lambda k: k.lower())
  print('Friends after sortin:', friends)

  i = 0
  for friend in friends:
      i = i + 1
      print(i, ') ', friend, sep='', end=(' ' * 3))

  print('\n\nSelect user or press <return> to go back to main menu')
  friend_input = input()

  if friend_input != '':
    idx_new_friend = int(friend_input) - 1
    print('idx_new_friend:', idx_new_friend)
    new_friend_screen_name = friends[idx_new_friend]
    print('new friend screen name:', new_friend_screen_name)
    current_username = new_friend_screen_name
    user = twitterApi.get_user(current_username)



def show_most_recent_tweet(twitter_user):
  print(f'Most recent tweet for {twitter_user.screen_name}:')
  print('  ', twitter_user.status.text)

  # check for link
  link_match = re.search('http\S*', twitter_user.status.text)
  if link_match != None:
    print('1) open link in browser')
    print('<enter> to go back to the main menu')
    recent_tweet_input = input()

    if recent_tweet_input == '1':
      url_link = link_match.group(0)
      os_name = platform.system()
      print(f'os_name: {os_name}')
      if os_name == 'Windows':
        os.system(f'start msedge {url_link}')
      else:
        print('OS not currently supported')


def show_most_recent_tweets(twitter_user, num_tweets, twitterApi):
    user_tweets = twitterApi.user_timeline(screen_name=twitter_user.screen_name, count=num_tweets)

    for tweet in user_tweets:
      print('\n')
      print('*' * 20, tweet.created_at, '*' * 20, sep='')
      print(f'  {tweet.text}')
      # print(tweet)

    print('*' * 80, sep='')



############### main part ##################

print('__name__=', __name__)


def main():
    global user
    global current_username

    num_args = len(sys.argv)
    if num_args < 2:
        print('\nMissing twitter username')
        sys.exit(0)

    print('Starting')

    # print('settings key:' + settings_mine.access_token)

    auth = tweepy.OAuthHandler(settings_mine.consumer_key,
                           settings_mine.consumer_secret)

    auth.set_access_token(settings_mine.access_token,
                      settings_mine.access_token_secret)

    api = tweepy.API(auth, wait_on_rate_limit=True)
                 # ,wait_on_rate_limit_notify=True)

    current_username = sys.argv[1]
    if IS_DEBUGGING:
        print('\ncurrent_username: |', current_username, '|', sep='')

    user = api.get_user(screen_name=current_username)


    user_input = ''
    while user_input != 'q':
        print('\n' * 200)

        if (user_input == 'a'):
            show_followers_count(user)
        elif (user_input == 'b'):
            show_friends(usr=user, twitterApi=api)
        elif (user_input == 'c'):
            show_description(user)
        elif (user_input == 'd'):
            show_most_recent_tweet(user)
        elif (user_input == 'e'):
            show_most_recent_tweets(user, 5, api)

        print('\n')

        if (IS_DEBUGGING):
          print("user:", user)

        print('Current username: ', current_username, ' (', user.name, ')')

        print('\n\n')
        print('a) display followers count')
        print('b) display accounts this user follows')
        print('c) display description')
        print('d) display most recent tweet')
        print('e) display most recent tweets')
        print('q) quit')
        user_input = input()

    print('\nDone.\n')


if __name__ == '__main__':
    main()




