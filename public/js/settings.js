const notifsToggle = document.querySelector('#allow_noti')
const notificationSettings = document.querySelector('#notificationSettings')

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}

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

const inputs = document.querySelectorAll('input[type="checkbox"]')
const colorInput = document.querySelector('input[type="color"]')
const csrfToken = document.querySelector('input[name="_token"]').value

function sendRequest(data) {
  let xhr = new XMLHttpRequest();
  xhr.open("PATCH", 'settings');
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.setRequestHeader("Accept", "application/json");
  xhr.send(encodeForAjax(data))
}

inputs.forEach(input => {
  input.addEventListener('change', function() {
    sendRequest({
      '_token' : csrfToken,
      [input.getAttribute('id')] : input.checked ? 1 : 0
    })
  })
})

if (colorInput) colorInput.addEventListener('change', function() {
  sendRequest({
    '_token' : csrfToken,
    [colorInput.getAttribute('id')] : colorInput.value
  })
})
