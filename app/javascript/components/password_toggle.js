function togglePassword() {
  $('[data-action="toggle-password"]').on("click", function(e) {
    const eyeOn = 'fa-eye';
    const eyeOff = 'fa-eye-slash';
    const icon = $(e.target);
    const target = icon.attr("data-target");

    if (!target) { return; }

    const passwordInput = $(`#${target}`);

    if (passwordInput.length === 0) {
      return;
    }
    if (passwordInput.attr('type') === 'password') {
      icon.removeClass(eyeOn);
      icon.addClass(eyeOff);
      passwordInput.attr('type', 'text');
    } else {
      icon.addClass(eyeOn);
      icon.removeClass(eyeOff);
      passwordInput.attr('type', 'password');
    }

  })
}
document.addEventListener('turbo:load', togglePassword)
