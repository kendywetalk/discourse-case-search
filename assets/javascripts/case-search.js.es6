import { withPluginApi } from 'discourse/lib/plugin-api';
import { showModal } from 'discourse/lib/modal';

export default {
  name: 'case-search-integration',

  initialize() {
    withPluginApi('0.8.7', (api) => {
      api.modifyClass('component:search-menu', {
        keyDown(e) {
          this._super(e);

          const caseNumber = e.target.value;
          if (caseNumber.startsWith('G-')) {
            fetch(`/case-search?case_number=${encodeURIComponent(caseNumber)}`)
              .then(response => response.json())
              .then(data => {
                if (data.status === 'found') {
                  showModal('case-search-result', { model: data.data });
                } else {
                  showModal('case-search-result', { model: { message: 'Case not found' } });
                }
              })
              .catch(err => {
                console.error('Error searching case:', err);
              });
          }
        }
      });
    });
  }
};

// Create a modal template to display search results
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
