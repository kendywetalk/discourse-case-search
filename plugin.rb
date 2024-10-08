# name: discourse-case-search
# about: A plugin to search for cases in Discourse
# version: 0.1
# authors: kendywetalk

enabled_site_setting :case_search_enabled

register_asset "javascripts/case-search.js.es6"

after_initialize do
  module ::CaseSearch
    class Engine < ::Rails::Engine
      engine_name "case_search"
      isolate_namespace CaseSearch
    end
  end

  require_dependency "application_controller"
  class CaseSearch::CaseSearchController < ::ApplicationController
    requires_plugin ::CaseSearch

    def search
      case_number = params[:case_number]
      if case_number.blank?
        render json: { status: "error", message: "Case number is required" }, status: 400
      else
        response = Net::HTTP.get_response(URI("http://192.168.1.44:5000/search?case_number=#{case_number}"))
        render json: JSON.parse(response.body)
      end
    end
  end

  CaseSearch::Engine.routes.draw do
    get "/search" => "case_search#search"
  end

  Discourse::Application.routes.append do
    mount ::CaseSearch::Engine, at: "/case-search"
  end
end
