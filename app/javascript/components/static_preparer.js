document.addEventListener("DOMContentLoaded", function(event) {
  const placeCheckbox = document.getElementById('toggle-menu-place');
  const noShowCheckbox = document.getElementById('toggle-menu-no-show');
  const justifCheckbox = document.getElementById('toggle-menu-justif');
  const processCheckbox = document.getElementById('toggle-menu-process');

  const placePictoClosed = document.getElementById('menu-place-picto-right');
  const noShowPictoClosed = document.getElementById('menu-no-show-picto-right');
  const justifPictoClosed = document.getElementById('menu-justif-picto-right');
  const processPictoClosed = document.getElementById('menu-process-picto-right');

  const placePictoOpened = document.getElementById('menu-place-picto-down');
  const noShowPictoOpened = document.getElementById('menu-no-show-picto-down');
  const justifPictoOpened = document.getElementById('menu-justif-picto-down');
  const processPictoOpened = document.getElementById('menu-process-picto-down');

  placeCheckbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      placePictoClosed.classList.add('preparer-menu-picto-inactive');
      placePictoClosed.classList.remove('preparer-menu-picto-active');
      placePictoOpened.classList.add('preparer-menu-picto-active');
      placePictoOpened.classList.remove('preparer-menu-picto-inactive');
    }

    if(e.target.checked === false) {
      placePictoClosed.classList.add('preparer-menu-picto-active');
      placePictoClosed.classList.remove('preparer-menu-picto-inactive');
      placePictoOpened.classList.add('preparer-menu-picto-inactive');
      placePictoOpened.classList.remove('preparer-menu-picto-active');
    }
  });

  noShowCheckbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      noShowPictoClosed.classList.add('preparer-menu-picto-inactive');
      noShowPictoClosed.classList.remove('preparer-menu-picto-active');
      noShowPictoOpened.classList.add('preparer-menu-picto-active');
      noShowPictoOpened.classList.remove('preparer-menu-picto-inactive');
    }

    if(e.target.checked === false) {
      noShowPictoClosed.classList.add('preparer-menu-picto-active');
      noShowPictoClosed.classList.remove('preparer-menu-picto-inactive');
      noShowPictoOpened.classList.add('preparer-menu-picto-inactive');
      noShowPictoOpened.classList.remove('preparer-menu-picto-active');
    }
  });

  justifCheckbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      justifPictoClosed.classList.add('preparer-menu-picto-inactive');
      justifPictoClosed.classList.remove('preparer-menu-picto-active');
      justifPictoOpened.classList.add('preparer-menu-picto-active');
      justifPictoOpened.classList.remove('preparer-menu-picto-inactive');
    }

    if(e.target.checked === false) {
      justifPictoClosed.classList.add('preparer-menu-picto-active');
      justifPictoClosed.classList.remove('preparer-menu-picto-inactive');
      justifPictoOpened.classList.add('preparer-menu-picto-inactive');
      justifPictoOpened.classList.remove('preparer-menu-picto-active');
    }
  });

  processCheckbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      processPictoClosed.classList.add('preparer-menu-picto-inactive');
      processPictoClosed.classList.remove('preparer-menu-picto-active');
      processPictoOpened.classList.add('preparer-menu-picto-active');
      processPictoOpened.classList.remove('preparer-menu-picto-inactive');
    }

    if(e.target.checked === false) {
      processPictoClosed.classList.add('preparer-menu-picto-active');
      processPictoClosed.classList.remove('preparer-menu-picto-inactive');
      processPictoOpened.classList.add('preparer-menu-picto-inactive');
      processPictoOpened.classList.remove('preparer-menu-picto-active');
    }
  });
});
