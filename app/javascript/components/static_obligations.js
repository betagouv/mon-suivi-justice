document.addEventListener("DOMContentLoaded", function(event) {
  ['op1', 'op2', 'op3', 'op4', 'op5', 'op6', 'op7', 'op7bis', 'op8', 'op9', 'op10',
   'op11', 'op12', 'op13', 'op14', 'op15', 'op16', 'op17', 'op18', 'op18bis', 'op19', 'op20',
   'op21', 'op22', 'op23', 'op24', 'op25'].forEach(menu_id => updatePictos(menu_id));
});

function updatePictos(menu_id) {
  const checkbox = document.getElementById('toggle-' + menu_id);
  const pictoClosed = document.getElementById(menu_id + '-picto-down');
  const pictoOpened = document.getElementById(menu_id + '-picto-up');

  checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      pictoClosed.classList.add('static-dropdown-picto-inactive');
      pictoClosed.classList.remove('static-dropdown-picto-active');
      pictoOpened.classList.add('static-dropdown-picto-active');
      pictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      pictoClosed.classList.add('static-dropdown-picto-active');
      pictoClosed.classList.remove('static-dropdown-picto-inactive');
      pictoOpened.classList.add('static-dropdown-picto-inactive');
      pictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });
}
