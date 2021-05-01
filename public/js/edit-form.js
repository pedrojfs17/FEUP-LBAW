const toggleButtons = document.querySelectorAll('.edit-button')
const csrfToken = document.querySelector('input[name="_token"]').value

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
      sendPatchAjaxRequest(button.dataset.href, {
        [button.dataset.editInput] : input.value,
        "_token": csrfToken,
      }, window[button.dataset.onEdit])
    }
  })
})

function updateProjectName(project) {
  const title = document.querySelector('#project-title')
  if (title) title.innerText = project.name
}

function sendPatchAjaxRequest(route, data, successFunction) {
  const xhr = new XMLHttpRequest();
  xhr.open("PATCH", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      if (successFunction) successFunction(JSON.parse(this.response))
    }
  };

  xhr.send(encodeForAjax(data));
}
