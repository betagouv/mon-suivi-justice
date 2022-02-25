document.addEventListener("DOMContentLoaded", function (event) {
  var scrollpos = sessionStorage.getItem('scrollpos');
  if (scrollpos) {
    window.scrollTo(0, scrollpos);
    sessionStorage.removeItem('scrollpos');
  }
});

window.addEventListener("beforeunload", function (e) {
  sessionStorage.setItem('scrollpos', window.scrollY);
});
