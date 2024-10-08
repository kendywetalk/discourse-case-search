import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "case-search",

  initialize(container) {
    withPluginApi("0.8", (api) => {
      api.onToolbarCreate((toolbar) => {
        toolbar.addButton({
          icon: "search",
          label: "Search Case",
          action() {
            let caseNumber = prompt("Enter the Case Number:");
            if (caseNumber) {
              $.ajax({
                url: `/case-search/search?case_number=${caseNumber}`,
                type: "GET",
                success: function (response) {
                  if (response.status === "found") {
                    alert(`Case Found: ${JSON.stringify(response.data)}`);
                  } else {
                    alert("Case not found");
                  }
                },
                error: function () {
                  alert("Error occurred while searching");
                },
              });
            }
          },
        });
      });
    });
  },
};
