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

  // Make ajax call the tj and spips here ?var menuId = $( "ul.nav" ).first().attr( "id" );
  var request = $.ajax({
    url: "/cities/" + e.target.value + "/services",
    method: "GET",
  });
  
  request.done(function( res ) {
    console.log("retour rails", res, res.length)

    if (res.length === 1) {
      $("#city-organizations").html( `Attention Mon suivi Justice n’est déployé que pour le ${res[0].name}. Vous ne pourrez poursuivre la prise de rendez-vous que pour ce service` );
    } else {
      $("#city-organizations").html('');
    }
  });
  
  request.fail(function( jqXHR, textStatus ) {
    alert( "Request failed: " + textStatus );
  });


 });

