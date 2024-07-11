// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
import { Turbo } from "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "./jquery"
import "@nathanvda/cocoon"
import "trix"
import "@rails/actiontext"
import "./controllers"
import "./components/password_toggle"
import "./channels"

import "@fortawesome/fontawesome-free/js/all";

Rails.start()
ActiveStorage.start()