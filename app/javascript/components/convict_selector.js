import $ from 'jquery';
import Rails from '@rails/ujs';
import 'select2';
import 'select2/dist/css/select2.css';

document.addEventListener('turbolinks:load',function() {
  $('#convict-name-autocomplete').select2({
    selectionCssClass : 'custom-select2-input',
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
    url: '/display_is_cpip?convict_id=' + convict_id
  });
}
