document.addEventListener("DOMContentLoaded", function(event) {
  const amenagement1Checkbox = document.getElementById('toggle-menu-amenagement1');
  const am1PictoClosed = document.getElementById('menu-am1-picto-right');
  const am1PictoOpened = document.getElementById('menu-am1-picto-down');

  amenagement1Checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      am1PictoClosed.classList.add('static-dropdown-picto-inactive');
      am1PictoClosed.classList.remove('static-dropdown-picto-active');
      am1PictoOpened.classList.add('static-dropdown-picto-active');
      am1PictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      am1PictoClosed.classList.add('static-dropdown-picto-active');
      am1PictoClosed.classList.remove('static-dropdown-picto-inactive');
      am1PictoOpened.classList.add('static-dropdown-picto-inactive');
      am1PictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });

  const amenagement2Checkbox = document.getElementById('toggle-menu-amenagement2');
  const am2PictoClosed = document.getElementById('menu-am2-picto-right');
  const am2PictoOpened = document.getElementById('menu-am2-picto-down');

  amenagement2Checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      am2PictoClosed.classList.add('static-dropdown-picto-inactive');
      am2PictoClosed.classList.remove('static-dropdown-picto-active');
      am2PictoOpened.classList.add('static-dropdown-picto-active');
      am2PictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      am2PictoClosed.classList.add('static-dropdown-picto-active');
      am2PictoClosed.classList.remove('static-dropdown-picto-inactive');
      am2PictoOpened.classList.add('static-dropdown-picto-inactive');
      am2PictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });

  const amenagement3Checkbox = document.getElementById('toggle-menu-amenagement3');
  const am3PictoClosed = document.getElementById('menu-am3-picto-right');
  const am3PictoOpened = document.getElementById('menu-am3-picto-down');

  amenagement3Checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      am3PictoClosed.classList.add('static-dropdown-picto-inactive');
      am3PictoClosed.classList.remove('static-dropdown-picto-active');
      am3PictoOpened.classList.add('static-dropdown-picto-active');
      am3PictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      am3PictoClosed.classList.add('static-dropdown-picto-active');
      am3PictoClosed.classList.remove('static-dropdown-picto-inactive');
      am3PictoOpened.classList.add('static-dropdown-picto-inactive');
      am3PictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });

  const amenagement4Checkbox = document.getElementById('toggle-menu-amenagement4');
  const am4PictoClosed = document.getElementById('menu-am4-picto-right');
  const am4PictoOpened = document.getElementById('menu-am4-picto-down');

  amenagement4Checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      am4PictoClosed.classList.add('static-dropdown-picto-inactive');
      am4PictoClosed.classList.remove('static-dropdown-picto-active');
      am4PictoOpened.classList.add('static-dropdown-picto-active');
      am4PictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      am4PictoClosed.classList.add('static-dropdown-picto-active');
      am4PictoClosed.classList.remove('static-dropdown-picto-inactive');
      am4PictoOpened.classList.add('static-dropdown-picto-inactive');
      am4PictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });

  const amenagement5Checkbox = document.getElementById('toggle-menu-amenagement5');
  const am5PictoClosed = document.getElementById('menu-am5-picto-right');
  const am5PictoOpened = document.getElementById('menu-am5-picto-down');

  amenagement5Checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      am5PictoClosed.classList.add('static-dropdown-picto-inactive');
      am5PictoClosed.classList.remove('static-dropdown-picto-active');
      am5PictoOpened.classList.add('static-dropdown-picto-active');
      am5PictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      am5PictoClosed.classList.add('static-dropdown-picto-active');
      am5PictoClosed.classList.remove('static-dropdown-picto-inactive');
      am5PictoOpened.classList.add('static-dropdown-picto-inactive');
      am5PictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });

  const amenagement6Checkbox = document.getElementById('toggle-menu-amenagement6');
  const am6PictoClosed = document.getElementById('menu-am6-picto-right');
  const am6PictoOpened = document.getElementById('menu-am6-picto-down');

  amenagement6Checkbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      am6PictoClosed.classList.add('static-dropdown-picto-inactive');
      am6PictoClosed.classList.remove('static-dropdown-picto-active');
      am6PictoOpened.classList.add('static-dropdown-picto-active');
      am6PictoOpened.classList.remove('static-dropdown-picto-inactive');
    }

    if(e.target.checked === false) {
      am6PictoClosed.classList.add('static-dropdown-picto-active');
      am6PictoClosed.classList.remove('static-dropdown-picto-inactive');
      am6PictoOpened.classList.add('static-dropdown-picto-inactive');
      am6PictoOpened.classList.remove('static-dropdown-picto-active');
    }
  });
});
