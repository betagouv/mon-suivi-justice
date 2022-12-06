import consumer from "./consumer"

consumer.subscriptions.create("Noticed::ConvictInvitationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connected")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("disconnected")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data)
    const container = $("#user-notifications-container");
    const notif = `
    <div class="fr-alert fr-alert--${data.type} fr-alert--sm">
      <h3 class="fr-alert__title">
        l'invitation ${data.status === 'pending' ? "est en cours d'envoi" : "a été envoyée" } à ${data.invitation_params.first_name} ${data.invitation_params.last_name}
      </h3>
      <button class="fr-btn--close fr-btn" title="Masquer le message" onclick="const alert = this.parentNode; alert.parentNode.removeChild(alert)">
          Masquer le message
      </button>
    </div>
    `
    const counterContainer = $("#user-notification-counter-container");
    const value = Number.parseInt(counterContainer.text())
    const newValue = value + 1;
    counterContainer.text(newValue)
    container.append(notif)
  }
});
