require("components/modal");
require("components/keep_scroll");


document.addEventListener("DOMContentLoaded", function (event) {
    document.addEventListener('input', function (e) {
        e.target.form.submit()
    });
});
