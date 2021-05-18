let csrf = document.querySelector('input[name="_token"]')
const csrfToken = csrf ? csrf.value : ''

/* AJAX FUNCTIONS */

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}

function sendAjaxRequest(method, url, data, onSuccess, onError) {
  let request = new XMLHttpRequest()

  request.onreadystatechange = function() {
    if (request.readyState === XMLHttpRequest.DONE) {
      let response = JSON.parse(this.responseText)
      if (request.status === 200) {
        if (onSuccess) onSuccess(response)
        if (response.message) showMessage(response.message)
      }
      else {
        if (onError) onError(response)
      }
    }
  }

  request.open(method, url, true)
  request.setRequestHeader("Accept", "application/json")
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  request.send(data)
}

function showMessage(message) {
  const container = document.querySelector('#message-container')
  let elem = document.createElement('div')
  elem.innerHTML = message
  let element = elem.children[0]

  container.append(element)
  let toast = new bootstrap.Toast(element, {});
  toast.show()

  element.addEventListener('hidden.bs.toast', function () {
    element.remove()
  })
}


/* FORMS */

const createForms = document.querySelectorAll('.create-form')
const editForms = document.querySelectorAll('.edit-form')

createForms.forEach(form => addFormEventListener(form, "POST"))
editForms.forEach(form => addFormEventListener(form, "PATCH"))

function addFormEventListener(form, method) {
  form.addEventListener('submit', function(e) {
    e.preventDefault()

    if (!window[form.dataset.validateFunction]()) {
      e.stopPropagation()
      form.classList.add('was-validated')
      return
    }

    let object = {};
    new FormData(form).forEach((value, key) => object[key] = value);

    let onError = function(response) {
      serverSideValidation(form, response)
    }

    sendAjaxRequest(method, form.dataset.href, encodeForAjax(object), window[form.dataset.onSubmit], onError)
  })
}

function addTagElement(response) {
  const tagsSection = document.getElementById('project-tags')

  let div = document.createElement('div')
  div.innerHTML = response.delete_tag
  tagsSection.append(div.children[0])

  addDeleteEventListener(tagsSection.querySelector('div:last-of-type'))
}

function addTaskElement(task) {
  const tasks = document.getElementById('overview')
  tasks.innerHTML = task['taskCard'] + tasks.innerHTML
}


/* DELETE BUTTONS */

const deleteButtons = document.querySelectorAll('.delete-button')
const removeButtons = document.querySelectorAll('.remove-button')

function addDeleteEventListener(button, removeElements) {
  button.addEventListener('click', function(e) {
    e.preventDefault()

    let callback = function () {
      if (removeElements)
        removeElements.forEach(element => element.remove())
      else
        button.remove()
    }

    sendAjaxRequest("DELETE", button.dataset.href, encodeForAjax({ "_token" : csrfToken }), callback)
  })
}

deleteButtons.forEach(button => addDeleteEventListener(button))
removeButtons.forEach(button => addDeleteEventListener(button, [button.parentElement.parentElement]))


/* EDIT BUTTONS */

const toggleButtons = document.querySelectorAll('.edit-button')
const changeRoleButtons = document.querySelectorAll('.edit-role-button')
const settingsToggles = document.querySelectorAll('.settings-button')
const colorInput = document.querySelectorAll('.color-input')

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

function addPatchOnClickEventListener(button) {
  button.addEventListener('click', function(e) {
    e.preventDefault()
    let data = {
      'member_role' : button.innerText,
      "_token": csrfToken,
    }
    sendAjaxRequest("PATCH", button.dataset.href, encodeForAjax(data), window[button.dataset.onEdit])
  })
}

toggleButtons.forEach(button => addUpdateEventListener(button))
changeRoleButtons.forEach(button => addPatchOnClickEventListener(button))

settingsToggles.forEach(button => {
  button.addEventListener('change', function(e) {
    e.preventDefault()
    let data = {
      [button.getAttribute('id')] : button.checked ? 1 : 0,
      "_token": csrfToken,
    }
    sendAjaxRequest("PATCH", "settings", encodeForAjax(data))
  })
})

colorInput.forEach(button => {
  button.addEventListener('change', function(e) {
    e.preventDefault()
    let data = {
      [button.getAttribute('id')] : button.value,
      "_token": csrfToken,
    }
    sendAjaxRequest("PATCH", "settings", encodeForAjax(data))
  })
})

function updateProjectName(project) {
  const title = document.querySelector('#project-title')
  if (title) title.innerText = project.name
}

function updateUserRole(response) {
  const memberCard = document.querySelector('#role-' + response.member.username)
  memberCard.innerHTML = response.member.role
}


/* GET ELEMENTS */

const openTaskButtons = document.querySelectorAll('.open-task')

function addGetEventListener(button, data, func) {
  button.addEventListener('click', function(e) {
    e.preventDefault()
    let requestUrl = button.dataset.href + (data ? '?' + encodeForAjax(data) : '')
    sendAjaxRequest("GET", requestUrl, null, func)
  })
}

openTaskButtons.forEach(button => {
  let callback = function(responseText) {
    onModalReceived(responseText, button)
  }
  addGetEventListener(button, null, callback)
})

function onModalReceived(response, button) {
  const div = document.querySelector('.modal-container')
  div.innerHTML = ""

  let elem = document.createElement('div')
  elem.innerHTML = response.taskModal
  let element = elem.children[0]
  div.append(element)

  let modal = new bootstrap.Modal(document.getElementById(button.dataset.target), {});
  modal.show()
  addModalEventListeners(element)
}

function addModalEventListeners(element) {
  tagEventListener(element)
  element.querySelectorAll('.delete-task-button').forEach(button => addDeleteEventListener(button,[element,document.getElementById('task-'+element.dataset.id)]))
}
