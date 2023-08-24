import "../components/modal";
import "../components/keep_scroll";

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
    e.target.form.submit();
  }
});
