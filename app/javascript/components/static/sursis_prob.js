import { updatePictos } from "./dropdown";

document.addEventListener("DOMContentLoaded", function(event) {
  ['sursis-prob1', 'sursis-prob2', 'sursis-prob3', 'sursis-prob4', 'sursis-prob5'].forEach(menu_id => updatePictos(menu_id));
});
