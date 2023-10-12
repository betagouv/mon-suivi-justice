document.addEventListener('turbo:load',function() {
  $('#agent-name-autocomplete').select2({
    selectionCssClass : 'custom-select2-input',
    sorter: data => data.sort((a, b) => a.text.localeCompare(b.text)),
    language: {
      noResults: function () {
        return 'Aucun résultat trouvé';
      }
    }
  });
});

$(document).on('select2:open', () => {
  document.querySelector('.select2-search__field').focus();
});
