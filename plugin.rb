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

# Modal Template for Search Results
discoursePluginRegistry.registerTemplate('case-search-result', {
  componentName: 'modal-base',
  title: 'Case Search Result',
  body(model) {
    if (model.message) {
      return `<p>${model.message}</p>`;
    }
    return `
      <div>
        <h4>Case Number: ${model.Case_Number}</h4>
        <p><strong>Priority Date:</strong> ${model.Priority_Date}</p>
        <p><strong>Draft Date:</strong> ${model.Draft_Date}</p>
        <p><strong>Audit Date:</strong> ${model.Audit_Date}</p>
        <p><strong>Result Date:</strong> ${model.Result_Date}</p>
        <p><strong>Status:</strong> ${model.Status}</p>
        <p><strong>Days to Result:</strong> ${model.Days_To_Result}</p>
        <p><strong>Days Pending:</strong> ${model.Days_Pending}</p>
        <p><strong>Employer Name:</strong> ${model.Employer_Name}</p>
        <p><strong>Job Title:</strong> ${model.Job_Title}</p>
      </div>
    `;
  }
});
