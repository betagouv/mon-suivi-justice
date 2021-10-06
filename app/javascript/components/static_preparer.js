document.addEventListener("DOMContentLoaded", function(event) {
  const headSpipCheckbox = document.getElementById('toggle-head-spip');
  const headTribunalCheckbox = document.getElementById('toggle-head-tribunal');
  const headSpipLabel = document.getElementById('toggle-head-label-spip');
  const headTribunalLabel = document.getElementById('toggle-head-label-tribunal');

  headSpipCheckbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      headTribunalCheckbox.checked = false;
      headSpipLabel.classList.add('preparer-active');
      headTribunalLabel.classList.remove('preparer-active');
    }

    if(e.target.checked === false) {
      headSpipLabel.classList.remove('preparer-active');
    }
  });

  headTribunalCheckbox.addEventListener('change', e => {
    if(e.target.checked === true) {
      headSpipCheckbox.checked = false;
      headTribunalLabel.classList.add('preparer-active');
      headSpipLabel.classList.remove('preparer-active');
    }

    if(e.target.checked === false) {
      headTribunalLabel.classList.remove('preparer-active');
    }
  });
});
