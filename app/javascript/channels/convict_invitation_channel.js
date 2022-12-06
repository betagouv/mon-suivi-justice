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
      <p>
        l'invitation à ${data.invitation_params.first_name} ${data.invitation_params.last_name} ${data.status === 'pending' ? "est en cours d'envoi" : "a été envoyée"}
      </p>
    </div>
    `
    console.log(container)
    container.append(notif)
  }
});
