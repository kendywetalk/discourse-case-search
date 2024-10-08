require 'net/http'
require 'json'

module ::CaseSearch
  class SearchController < ::ApplicationController
    requires_plugin "discourse-case-search"

    def search_case_number
      case_number = params[:case_number]
      uri = URI("http://localhost:5000/search?case_number=#{URI.encode(case_number)}")
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

discourse_plugin_registry.register_route(:get, '/case-search', 'CaseSearch::SearchController', :search_case_number)
