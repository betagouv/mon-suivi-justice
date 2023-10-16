function togglePassword() {
  $('[data-action="toggle-password"]').on("click", function(e) {
    const eyeOn = 'fr-icon-eye-fill';
    const eyeOff = 'fr-icon-eye-off-fill';
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
