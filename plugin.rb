require 'net/http'
require 'json'

module ::CaseSearch
  class SearchController < ::ActionController::Base
    requires_plugin "discourse-case-search"

    def search_case_number
      case_number = params[:case_number]
      uri = URI("http://flask-api-host:5000/search?case_number=#{URI.encode_www_form_component(case_number)}")
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
