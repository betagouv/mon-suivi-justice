import consumer from "./consumer"
import { v4 as uuidv4 } from 'uuid';

const subscription = consumer.subscriptions.create("Noticed::ConvictInvitationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connected")
    window.addEventListener("beforeunload", this.markAllAsRead)
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("disconnected")
    window.removeEventListener("beforeunload", this.markAllAsRead)
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    displayToast(data);
    incrementNotificationCounter();
    changeInvitationText(data);
  },

  markAllAsRead() {
    const location = getClearLocation();
    if(location === "/user/user_notifications") {
      console.log("exiting notifications - mark all notifications as read")
      // Calls `Noticed::ConvictInvitationChannel#mark_all_as_read` on the server.
      subscription.perform("mark_all_as_read")
    }
  },
});

function displayToast(data) {
  const container = $("#user-notifications-container");
  const notificationId = uuidv4();
  const notif = getNotif(notificationId, data);
  container.append(notif);

  removeNotif(notificationId)
}

function changeInvitationText(data) {
  switch (data.status) {
    case 'pending':
      $('#convict-invitation-text').text('Invitation en cours d\'envoi')
      $('#convict-invitation-button').prop('disabled', true)
      break;
    case 'sent':
      const reinvited = `Relancé le ${formatDate(data.last_invitation_date)}`;
      const invited = `Invité le ${formatDate(data.last_invitation_date)}`;
      const invitationText = data.invitation_count > 1 ? reinvited : invited;
      $('#convict-invitation-text').text(invitationText)
      break;
  
    default:
      break;
  }
}

function formatDate(date) {
  return new Intl.DateTimeFormat('fr-FR', { dateStyle: 'full', timeStyle: 'short' }).format(new Date(date))
}

function incrementNotificationCounter() {
  const counterContainer = $("#user-notification-counter-container");
  const value = Number.parseInt(counterContainer.text(), 10) || 0;
  const newValue = value + 1;
  counterContainer.text(newValue)
}

function getNotif(id, data) {
  return `
  <div class="fr-alert fr-alert--${data.type} fr-alert--sm" id="${id}">
    <h3 class="fr-alert__title">
      L'invitation ${data.status === 'pending' ? "est en cours d'envoi" : "a été envoyée" } à ${data.invitation_params.first_name} ${data.invitation_params.last_name}
    </h3>
    <button class="fr-btn--close fr-btn" title="Masquer le message" onclick="const alert = this.parentNode; alert.parentNode.removeChild(alert)">
        Masquer le message
    </button>
  </div>
  `;
}

function removeNotif(id) {
  console.log(id)
  window.setTimeout(() => {
    const element = $(`#${id}`)
    element.fadeOut('slow', () => {
      element.remove()
    })
  }, 2000)
}

function getClearLocation() {
  // return /user/user_notifications instead of http://localhost:3001/user/user_notifications
  return window.location.href.toString().split(window.location.host)[1];
}
