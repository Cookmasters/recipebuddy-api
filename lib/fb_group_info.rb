require 'http'
require 'yaml'

config = YAML.safe_load(File.read('config/secrets.yml'))

def fb_api_path(path)
  'https://graph.facebook.com/v2.10/' + path
end

def call_fb_url(config, url)
  HTTP.headers('Accept' => 'application/json',
               'Authorization' => "OAuth #{config['fb_token']}").get(url)
end

fb_response = {}
fb_results = {}

## GOOD REPO (HAPPY)
group_name_id = 'RecipesAndCookingGuide'
group_url = fb_api_path(group_name_id)
fb_response[group_url] = call_fb_url(config, group_url)
group = fb_response[group_url].parse

fb_results['name'] = group['name']
# should be Recipes And Cooking Guide

fb_results['id'] = group['id']
# should be 236017159909583

posts_url = fb_api_path('236017159909583/posts')
fb_response[posts_url] = call_fb_url(config, posts_url)
data = fb_response[posts_url].parse
posts = data['data']

fb_results['posts'] = posts
posts.count
# should be 25 posts array

## BAD REPO (SAD)
bad_group_name_id = 'olcooker'
bad_group_url = fb_api_path(bad_group_name_id)
fb_response[bad_group_url] = call_fb_url(config, bad_group_url)
fb_response[bad_group_url].parse # makes sure any streaming finishes

File.write('spec/fixtures/fb_response.yml', fb_response.to_yaml)
File.write('spec/fixtures/fb_results.yml', fb_results.to_yaml)
