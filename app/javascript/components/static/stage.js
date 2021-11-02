import { updatePictos } from "./dropdown";

document.addEventListener("DOMContentLoaded", function(event) {
  ['stage1', 'stage2', 'stage3', 'stage4', 'stage5'].forEach(menu_id => updatePictos(menu_id));
});
