require("components/modal");
require("components/keep_scroll");

document.addEventListener('input', function (e) {
    const { target } = e;
    if (target.matches('#q_user_id_eq')) {
        e.target.form.submit()
    }
});
