const notifsToggle = document.querySelector('#allow_noti')
const notificationSettings = document.querySelector('#notificationSettings')

if (notifsToggle) {
    const notificationToggles = notificationSettings.querySelectorAll('input[type=checkbox]')
    const notificationLabels = notificationSettings.querySelectorAll('label')

    if (!notifsToggle.checked) {
        notificationToggles.forEach(toggle => toggle.disabled = true)
        notificationLabels.forEach(label => label.classList.add('text-muted'))
    }

    notifsToggle.addEventListener('change', function() {
        if (this.checked) {
            notificationToggles.forEach(toggle => toggle.disabled = false)
            notificationLabels.forEach(label => label.classList.remove('text-muted'))
        } else {
            notificationToggles.forEach(toggle => toggle.disabled = true)
            notificationLabels.forEach(label => label.classList.add('text-muted'))
        }
    });
}
