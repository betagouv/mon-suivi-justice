document.addEventListener("turbolinks:load", function() {
    const flash = document.querySelector('.notice');
    setTimeout(() => flash.style.display = 'none', 5000);    
});
