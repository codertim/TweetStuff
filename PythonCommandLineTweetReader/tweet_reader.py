
import tweepy
import settings_mine
import sys


def show_followers_count(usr):
  print('Followers count:' + str(usr.followers_count))


def show_description(usr):
  print('User Description: ' + usr.description)


def show_friends(usr):
  friends = []
  global current_username
  global user
  cursor = tweepy.Cursor(api.friends, screen_name='coder_tim', count=200)
  for friend in cursor.items(200):
      friends.append(friend.screen_name)

  friends = sorted(friends, key=lambda k: k.lower())
  print('Friends:', friends)
  # print('Friends: ', ', '.join(sorted(friends, key=lambda s: s.lower())))
  i = 0
  for friend in friends:
      i = i + 1
      print(i, ') ', friend, sep='', end=(' ' * 3))

  print('\n\nSelect user or press <return> to go back to main menu')
  friend_input = input()
  if friend_input != '':
    idx_new_friend = int(friend_input) -1
    print('idx_new_friend:', idx_new_friend)
    new_friend_screen_name = friends[idx_new_friend]
    print('new friend screen name:', new_friend_screen_name)
    current_username = new_friend_screen_name
    user = api.get_user(current_username)


############### main part ##################


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

api = tweepy.API(auth, wait_on_rate_limit=True,
                 wait_on_rate_limit_notify=True)

current_username = sys.argv[1]
user = api.get_user(current_username)


user_input = ''
while user_input != 'q':
    print('\n' * 100)

    if (user_input == 'a'):
        show_followers_count(user)
    elif (user_input == 'b'):
        show_friends(user)
    elif (user_input == 'c'):
        show_description(user)

    print('\n')

    print('Current username: ', current_username, ' (', user.name, ')')

    print('\n\n')

    print('a) display followers count')
    print('b) display accounts this user follows')
    print('c) display description')
    print('q) quit')
    user_input = input()



print('Done.')



import tweepy
import settings_mine
import sys


def show_followers_count(usr):
  print('Followers count:' + str(usr.followers_count))


def show_description(usr):
  print('User Description: ' + usr.description)


def show_friends(usr):
  friends = []
  global current_username
  global user
  cursor = tweepy.Cursor(api.friends, screen_name='coder_tim', count=200)
  for friend in cursor.items(200):
      friends.append(friend.screen_name)

  friends = sorted(friends, key=lambda k: k.lower())
  print('Friends:', friends)
  # print('Friends: ', ', '.join(sorted(friends, key=lambda s: s.lower())))
  i = 0
  for friend in friends:
      i = i + 1
      print(i, ') ', friend, sep='', end=(' ' * 3))

  print('\n\nSelect user or press <return> to go back to main menu')
  friend_input = input()
  if friend_input != '':
    idx_new_friend = int(friend_input) -1
    print('idx_new_friend:', idx_new_friend)
    new_friend_screen_name = friends[idx_new_friend]
    print('new friend screen name:', new_friend_screen_name)
    current_username = new_friend_screen_name
    user = api.get_user(current_username)



print('Starting')

# print('settings key:' + settings_mine.access_token)

auth = tweepy.OAuthHandler(settings_mine.consumer_key,
                           settings_mine.consumer_secret)

auth.set_access_token(settings_mine.access_token,
                      settings_mine.access_token_secret)

api = tweepy.API(auth, wait_on_rate_limit=True,
                 wait_on_rate_limit_notify=True)

current_username = sys.argv[1]
user = api.get_user(current_username)


user_input = ''
while user_input != 'q':
    print('\n' * 100)

    if (user_input == 'a'):
        show_followers_count(user)
    elif (user_input == 'b'):
        show_friends(user)
    elif (user_input == 'c'):
        show_description(user)

    print('\n')

    print('Current username: ', current_username, ' (', user.name, ')')

    print('\n\n')

    print('a) display followers count')
    print('b) display accounts this user follows')
    print('c) display description')
    print('q) quit')
    user_input = input()



print('Done.')


