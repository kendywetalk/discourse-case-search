# Plugin name: discourse-case-search
# about: Plugin to search case information from SQLite database without modifying PostgreSQL
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
      db_path = '/var/discourse/plugins/discourse-case-search/sheets_data.db' # Ensure the DB is accessible to the container
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
