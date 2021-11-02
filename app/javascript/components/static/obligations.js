import { updatePictos } from "./dropdown";

document.addEventListener("DOMContentLoaded", function(event) {
  ['op1', 'op2', 'op3', 'op4', 'op5', 'op6', 'op7', 'op7bis', 'op8', 'op9', 'op10',
   'op11', 'op12', 'op13', 'op14', 'op15', 'op16', 'op17', 'op18', 'op18bis', 'op19', 'op20',
   'op21', 'op22', 'op23', 'op24', 'op25'].forEach(menu_id => updatePictos(menu_id));
});
