require 'oauth'

# Fill the keys and secrets you retrieved after registering your app
api_key = '4bbe80b384678a280ed0c88f53067c59'
api_secret = '5e849b80c5a7455ea6edd1704bc381b9709a663abc1d0a8beb9ddd17223abb89'
user_token = '47e01e1152c2d361f2a20edaa9ddd3751aa1d49f9c048abaa6df8ae4e8300905'
user_secret = '9876abcd-123asdf-1122'

# Specify LinkedIn API endpoint
configuration = { :site => 'https://api.trello.com' }

# Use your API key and secret to instantiate consumer object
consumer = OAuth::Consumer.new(api_key, api_secret, configuration)

# Use your developer token and secret to instantiate access token object
access_token = OAuth::AccessToken.new(consumer, user_token, user_secret)

# Make call to LinkedIn to retrieve your own profile
response = access_token.get("https://trello.com/1/authorize?key=4bbe80b384678a280ed0c88f53067c59&name=My+Application&expiration=1day&response_type=token&scope=read,write")
puts response.body
