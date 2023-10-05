
import 'select2/dist/css/select2.css';

document.addEventListener('turbo:load',function(e) {
  $('.select2-container').remove();

  $('#profile-search-field').select2({
    selectionCssClass : 'profile-search-select2-input',
    placeholder: "Commencer à saisir un nom ou un téléphone",
    multiple: true,
    maximumSelectionSize: 1,
    width: 'resolve',
    sorter: data => data.sort((a, b) => a.text.localeCompare(b.text)),
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
    Turbo.visit(convict_path);
  });
});
