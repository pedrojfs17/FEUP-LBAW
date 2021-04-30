const toggleButtons = document.querySelectorAll('.edit-button')
const csrfTocken = document.querySelector('input[name="_token"]').value

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}

toggleButtons.forEach(button => {
  button.addEventListener('click', function() {
    const input = document.getElementById(button.dataset.editInput)

    if (input.disabled) {
      button.innerHTML = '<i class="bi bi-check2"></i>'
      input.disabled = false
    } else {
      button.innerHTML = '<i class="bi bi-pencil"></i>'
      input.disabled = true
      sendAjaxRequest(window.location.pathname, {
          [button.dataset.editInput] : input.value,
          "_token": csrfTocken,
        })
    }
  })
})

function sendAjaxRequest(route, data) {
  const xhr = new XMLHttpRequest();
  xhr.open("PATCH", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      console.log(xhr.status);
      console.log(xhr.responseText);
    }
  };

  xhr.send(encodeForAjax(data));
}
