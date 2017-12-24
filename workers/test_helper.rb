# frozen_string_literal: true

require 'webmock'
include WebMock::API

WebMock.enable!
WebMock.allow_net_connect!

stub_request(:post, LoadRecipesWorker.config.API_URL + '/faye')
  .to_return(status: 200, body: '', headers: {})
