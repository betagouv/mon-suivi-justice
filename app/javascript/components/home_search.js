import $ from 'jquery';
import 'select2';
import 'select2/dist/css/select2.css';

$(document).on('turbolinks:before-cache', function () {
  $('#home-search-field').select2('destroy');
});

document.addEventListener('turbolinks:load',function(e) {
  $('#home-search-field').select2({
    selectionCssClass : 'home-select2-input',
    placeholder: "Commencer à saisir le nom et choisir dans la liste",
    multiple: true,
    maximumSelectionSize: 1,
    width: 'resolve',
    language: {
      noResults: function () {
        return 'Aucun résultat trouvé';
      }
    }
  });

  $('.select2-search__field').focus();

  $('#home-search-field').on('select2:select', function (e) {
    $('#home-search-field').val(null).trigger('change');
    var convict_path = e.params.data.id;
    Turbolinks.visit(convict_path);
  });
});
