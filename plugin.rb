# name: discourse-case-search
# about: A plugin to search for case numbers in Discourse
# version: 0.1
# authors: Kendy
# url: https://github.com/kendywetalk/discourse-case-search

require 'net/http'
require 'json'

module ::CaseSearch
  class SearchController < ::ActionController::Base
    def search_case_number
      case_number = params[:case_number]
      uri = URI("http://127.0.0.1:5000/search?case_number=#{URI.encode_www_form_component(case_number)}")
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)

      if result['status'] == 'found'
        render json: { status: 'found', data: result['data'] }
      else
        render json: { status: 'not found' }
      end
    end
  end
end

# Register route to connect the controller to a URL endpoint
Discourse::Application.routes.append do
  get '/case-search' => 'case_search/search#search_case_number'
end
