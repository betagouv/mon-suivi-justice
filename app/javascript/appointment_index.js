import "./components/modal";
import "./components/keep_scroll";

function isValidDateFormat(dateStr) {
  const regex = /^20\d{2}-\d{2}-\d{2}$/;
  return regex.test(dateStr);
}

document.addEventListener("input", function (e) {
  const { target } = e;
  if (
    [
      "index-appointment-date-filter",
      "q_slot_agenda_place_id_eq",
      "q_slot_agenda_id_eq",
      "q_slot_appointment_type_id_eq",
      "q_user_id_eq",
    ].includes(target.id)
  ) {
    if (target.id === "index-appointment-date-filter") {
      if (isValidDateFormat(target.value)) {
        e.target.form.submit();
      } 
    } else {
      e.target.form.submit();
    }
  }
});
