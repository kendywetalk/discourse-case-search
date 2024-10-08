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
