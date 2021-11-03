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

exports.updatePictos = updatePictos;
