const editProfileButton = document.getElementById('editProfile')
const saveEditButton = document.getElementById('saveEdit')
const cancelEditButton = document.getElementById('cancelEdit')
const actions = document.getElementById('editActions')
const inputs = document.querySelectorAll('form input, form textarea')

function editProfileHandler(e){
  inputs.forEach(function (field) {
    if (field.name != '_token') {
      field.value = field.placeholder
      field.disabled = false
    }
  })
  actions.style.display = 'block'
  editProfileButton.style.display = 'none'
}

function saveEditHandler(e) {
  actions.style.display = 'none'
  editProfileButton.style = ''

  let data = {}
  inputs.forEach((field) => {
    if (field.value != field.placeholder || field.name === '_token') {
      data[field.name] = field.value
      if (field.name != '_token') {
        field.placeholder = field.value
      }
    }
    field.disabled = true
  })
  
  if (Object.keys(data).length === 1) return

  sendAjaxRequest('PATCH', saveEditButton.dataset.href, encodeForAjax(data), window[saveEditButton.dataset.onEdit])
}

function cancelEditHandler(e) {
  inputs.forEach((field) => {
    if (field.name != '_token')
      field.value = field.placeholder
    field.disabled = true
  })
  actions.style.display = 'none'
  editProfileButton.style = ''
}

if (editProfileButton) {
    editProfileButton.addEventListener('click', editProfileHandler)
}

if (saveEditButton) {
    saveEditButton.addEventListener('click', saveEditHandler)
}

if (cancelEditButton) {
    cancelEditButton.addEventListener('click', cancelEditHandler)
}
