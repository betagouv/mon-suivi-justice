document.addEventListener("turbo:frame-render", () => {
    console.log("listenner pour convicts search")
    const searchField = document.getElementById("convicts_search_field");
    const myConvictsCheckbox = document.getElementById("my_convicts_checkbox");
    const searchForm = document.getElementById("convicts_search_form");
  
    if (!searchField || !myConvictsCheckbox || !searchForm) {
      console.log("exit")
      return; // Exit the function if any of the elements don't exist
    }

    const triggerSearch = () => {
      clearTimeout(window.searchTimeout);
      window.searchTimeout = setTimeout(() => {
        searchForm.requestSubmit();
      }, 300);
    };
  
    searchField.addEventListener("keyup", triggerSearch);
    myConvictsCheckbox.addEventListener("change", triggerSearch);
  });