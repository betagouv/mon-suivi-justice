// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "@hotwired/turbo-rails"
import "./jquery"
import "@nathanvda/cocoon"
import "trix"
import "@rails/actiontext"
import "./controllers"
import "./components/profile_search"
import "./components/password_toggle"
import "./icons"
import "./channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()