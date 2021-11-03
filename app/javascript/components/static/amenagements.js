import { updatePictos } from "./dropdown";

document.addEventListener("DOMContentLoaded", function(event) {
  ['amenagement1', 'amenagement2', 'amenagement3', 'amenagement4', 'amenagement5', 'amenagement5'].forEach(menu_id => updatePictos(menu_id));
});
