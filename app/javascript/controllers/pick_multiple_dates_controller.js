import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr"
import { French } from "flatpickr/dist/l10n/fr.js"
import Holidays from "date-holidays";

const holidays = new Holidays('FR');
const thisYear = new Date().getFullYear();
const nextYear = thisYear + 1;
const thisYearHolidays = holidays.getHolidays(thisYear).map((holiday) => holiday.date);
const nextYearHolidays = holidays.getHolidays(nextYear).map((holiday) => holiday.date);
const oneYearFromNow = new Date();
oneYearFromNow.setFullYear(nextYear);
const options = { 
  mode: 'multiple', 
  minDate: 'today',
  maxDate: oneYearFromNow,
  locale: French,
  dateFormat: "Y-m-d",
  disable: [
    function(date) {
        // return true to disable
        return (date.getDay() === 0 || date.getDay() === 6);
    },
    ...thisYearHolidays,
    ...nextYearHolidays
  ]
}

export default class extends Controller {
  connect() {
    flatpickr(this.element, options)
  }
}