import $ from 'jquery';
import Rails from '@rails/ujs';
import 'select2';
import 'select2/dist/css/select2.css';

document.addEventListener('turbolinks:load',function() {
  console.log("Hello from city selector")
  $('#convict_city_id').select2({
    selectionCssClass : 'custom-select2-input',
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
