// notification on every track change.
(async function notifySongChange() {
  while (!Spicetify?.Player?.data) {
    await new Promise((resolve) => setTimeout(resolve, 300));
  }

  if (typeof Notification !== "undefined" && Notification.permission === "default") {
    Notification.requestPermission();
  }

  function notify(track) {
    const metadata = track?.metadata;
    if (!metadata) return;
    const title = metadata.title;
    const artist = metadata.artist_name;
    const icon = metadata.image_xlarge_url || metadata.image_url;
    try {
      new Notification(title, { body: artist, icon, silent: true });
    } catch (err) {
      console.error("[notify-song-change] failed to send notification", err);
    }
  }

  Spicetify.Player.addEventListener("songchange", () => {
    notify(Spicetify.Player.data?.item);
  });
})();
