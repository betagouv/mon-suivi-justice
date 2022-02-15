import $ from 'jquery';
import 'select2';
import 'select2/dist/css/select2.css';

document.addEventListener('turbolinks:load',function(e) {
  $('.select2-container').remove();

  $('#profile-search-field').select2({
    selectionCssClass : 'profile-search-select2-input',
    placeholder: "Commencer à saisir le nom ou le téléphone et choisir dans la liste",
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

  $('#profile-search-field').on('select2:select', function (e) {
    $('#profile-search-field').val(null).trigger('change');
    var convict_path = e.params.data.id;
    Turbolinks.visit(convict_path);
  });
});
