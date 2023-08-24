import $ from 'jquery';
import Rails from '@rails/ujs';
import select2 from 'select2';
select2($);
import 'select2/dist/css/select2.css';

document.addEventListener('turbo:load',function() {
  $('#convict-name-autocomplete').select2({
    selectionCssClass : 'custom-select2-input',
    sorter: data => data.sort((a, b) => a.text.localeCompare(b.text)),
    language: {
      noResults: function () {
        return 'Aucun résultat trouvé';
      }
    }
  });

  $('#convict-name-autocomplete').on('select2:select', () => {
    displayIsCpip($('#convict-name-autocomplete').val());
  });
});

$(document).on('select2:open', () => {
  document.querySelector('.select2-search__field').focus();
});

function displayIsCpip(convict_id) {
  Rails.ajax({
    type: 'GET',
    url: '/load_is_cpip?convict_id=' + convict_id
  });
}