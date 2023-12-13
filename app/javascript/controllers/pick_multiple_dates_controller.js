import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr"
import { French } from "flatpickr/dist/l10n/fr.js"
import Holidays from "date-holidays";

export default class extends Controller {
  connect() {
    const holidays = new Holidays('FR');
    const thisYear = new Date().getFullYear();
    const nextYear = thisYear + 1;
    const thisYearHolidays = holidays.getHolidays(thisYear).map((holiday) => holiday.date);
    const nextYearHolidays = holidays.getHolidays(nextYear).map((holiday) => holiday.date);
    
    flatpickr(this.element, { mode: 'multiple', minDate: 'today', locale: French, disable: [
      function(date) {
          // return true to disable
          return (date.getDay() === 0 || date.getDay() === 6);
      },
      ...thisYearHolidays,
      ...nextYearHolidays
    ]})
  }
}