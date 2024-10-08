# Plugin name: discourse-case-search
# about: Plugin to search case information in the database
# version: 1.0
# author: Kendy

require 'sqlite3'

after_initialize do
  # Add a route to handle the search request
  Discourse::Application.routes.append do
    get '/case_search' => 'case_search#search'
  end

  # Define the controller to handle the case search
  class ::CaseSearchController < ApplicationController
    requires_plugin 'discourse-case-search'

    def search
      case_number = params[:case_number]
      result = query_case_number(case_number)

      if result
        render_json_dump(format_result(result))
      else
        render_json_dump({ error: 'Case not found' })
      end
    end

    private

    def query_case_number(case_number)
      db_path = '/var/discourse/plugins/discourse-case-search/sheets_data.db' # Update this path to the actual location of your database
      db = SQLite3::Database.new(db_path)
      db.results_as_hash = true
      query = 'SELECT * FROM cases WHERE Case_Number = ?'
      result = db.execute(query, case_number).first
    ensure
      db&.close
    end

    def format_result(result)
      {
        case_number: result['Case_Number'],
        priority_date: result['Priority_Date'],
        draft_date: result['Draft_Date'],
        audit_date: result['Audit_Date'],
        result_date: result['Result_Date'],
        status: result['Status'],
        days_to_result: result['Days_To_Result'],
        days_pending: result['Days_Pending'],
        employer_name: result['Employer_Name'],
        job_title: result['Job_Title']
      }
    end
  end
end

# Extend the Discourse search UI to integrate the case search feature
DiscourseEvent.on(:before_search) do |search|
  if search.term.match?(/^G-\d{3,5}-\d{5,}$/)
    case_number = search.term.strip
    result = Discourse::Application.routes.call(
      Rack::MockRequest.env_for("/case_search?case_number=#{case_number}")
    )
    body = result[2].body.join
    search.add_custom_result({
      title: "Case Information for #{case_number}",
      raw: format_search_result(body),
      url: "/case_search?case_number=#{case_number}"
    }) if result[0] == 200
  end
end

# Helper method to format the search result
def format_search_result(body)
  result = JSON.parse(body)
  return "Case not found" if result['error']

  """
  **Case Number**: #{result['case_number']}
  **Priority Date**: #{result['priority_date']}
  **Draft Date**: #{result['draft_date']}
  **Audit Date**: #{result['audit_date']}
  **Result Date**: #{result['result_date']}
  **Status**: #{result['status']}
  **Days to Result**: #{result['days_to_result']}
  **Days Pending**: #{result['days_pending']}
  **Employer Name**: #{result['employer_name']}
  **Job Title**: #{result['job_title']}
  """
end
