import { updatePictos } from "./dropdown";

document.addEventListener("DOMContentLoaded", function(event) {
  ['tig1', 'tig2', 'tig3', 'tig4', 'tig5'].forEach(menu_id => updatePictos(menu_id));
});
