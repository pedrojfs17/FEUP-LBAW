const csrfToken = document.querySelector('input[name="_token"]').value

/* AJAX FUNCTIONS */

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}

function sendAjaxRequest(method, url, data, callback) {
  let request = new XMLHttpRequest()

  request.onreadystatechange = function() {
    if (request.readyState === XMLHttpRequest.DONE) {
      if (request.status === 200) {
        if (callback) callback(this.responseText)
      }
      else {
        console.log('There was an error ' + request);
      }
    }
  }

  request.open(method, url, true)
  request.setRequestHeader("Accept", "application/json")
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  request.send(data)
}


/* CREATE FORMS */

const createForms = document.querySelectorAll('.create-form')

function addCreateEventListener(form) {
  form.addEventListener('submit', function(e) {
    e.preventDefault()
    let object = {};
    new FormData(form).forEach((value, key) => object[key] = value);
    sendAjaxRequest("POST", form.dataset.href, encodeForAjax(object), window[form.dataset.onSubmit])
  })
}

createForms.forEach(form => addCreateEventListener(form))

function addTagElement(responseText) {
  const tagsSection = document.getElementById('project-tags')
  const tag = JSON.parse(responseText)

  tagsSection.innerHTML +=
    ' <p class="delete-tag delete-button d-inline-block m-0 my-1 py-1 px-3 px-sm-2 rounded text-bg-check" type="button" data-href="/api/project/' + tag.project + '/tag/' + tag.id + '" style="background-color: ' + tag.color + '">\n' +
    '   <small class="d-none d-sm-inline-block">' + tag.name + '</small>\n' +
    ' </p> '

  addDeleteEventListener(tagsSection.querySelector('p:last-of-type'))
}

function addTaskElement(responseText) {
  const tasks = document.getElementById('overview')
  const task = JSON.parse(responseText)

  console.log(task)
  tasks.innerHTML += task['taskCard'] + task['taskModal']
}


/* DELETE BUTTONS */

const deleteButtons = document.querySelectorAll('.delete-button')
const removeButtons = document.querySelectorAll('.remove-button')

function addDeleteEventListener(button, removeElement) {
  button.addEventListener('click', function(e) {
    e.preventDefault()

    let callback = function () {
      if (removeElement)
        removeElement.remove()
      else
        button.remove()
    }

    sendAjaxRequest("DELETE", button.dataset.href, encodeForAjax({ "_token" : csrfToken }), callback)
  })
}

deleteButtons.forEach(button => addDeleteEventListener(button))
removeButtons.forEach(button => addDeleteEventListener(button, button.parentElement.parentElement))


/* EDIT BUTTONS */

const toggleButtons = document.querySelectorAll('.edit-button')

function addUpdateEventListener(button) {
  button.addEventListener('click', function(e) {
    e.preventDefault()

    const input = document.getElementById(button.dataset.editInput)

    if (input.disabled) {
      button.innerHTML = '<i class="bi bi-check2"></i>'
      input.disabled = false
    } else {
      button.innerHTML = '<i class="bi bi-pencil"></i>'
      input.disabled = true
      let data = {
        [button.dataset.editInput] : input.value,
        "_token": csrfToken,
      }
      sendAjaxRequest("PATCH", button.dataset.href, encodeForAjax(data), window[button.dataset.onEdit])
    }
  })
}

toggleButtons.forEach(button => addUpdateEventListener(button))

function updateProjectName(responseText) {
  const project = JSON.parse(responseText)
  const title = document.querySelector('#project-title')
  if (title) title.innerText = project.name
}
