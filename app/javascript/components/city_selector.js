import $ from 'jquery';
import Rails from '@rails/ujs';
import 'select2';
import 'select2/dist/css/select2.css';

document.addEventListener('turbolinks:load',function() {
  $('#convict_city_id').select2({
    selectionCssClass : 'custom-select2-input city-selector',
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

// https://select2.org/programmatic-control/events#limiting-the-scope-of-the-change-event
$(document).on("select2:select", function (e) {

  // Make ajax call the tj and spips here ?


  $("#city-organizations").append( `<strong>Le SPIP et le TJ ${e.target.value}</strong>` );
 });

