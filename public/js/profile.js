const editProfileButton = document.getElementById('editProfile')
const saveEditButton = document.getElementById('saveEdit')
const cancelEditButton = document.getElementById('cancelEdit')
const actions = document.getElementById('editActions')
const inputs = document.querySelectorAll('form input')
const values = {}

function editProfileHandler(e){
  inputs.forEach(function (field) {
    values[field.id] = field.placeholder
    field.disabled = false
  })
  actions.style.display = 'block'
  editProfileButton.style.display = 'none'
}

function saveEditHandler(e) {
  actions.style.display = 'none'
  editProfileButton.style = ''

  let data = {}
  inputs.forEach((field) => {
    if (field.value) {
      data[field.name] = field.value
      if (field.name != '_token') {
        field.placeholder = field.value
        field.value = ''
      }
    }
    field.disabled = true
  })
  
  if (Object.keys(data).length === 1) return

  let request = new XMLHttpRequest()
  request.open('PATCH', e.target.dataset.href)
  request.setRequestHeader("Accept", "application/json");
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  request.onreadystatechange = () => {
    if (request.readyState === XMLHttpRequest.DONE) {
      let status = request.status
      if (status === 200) {
        console.log("Succ")
      } else {
        console.log("UnSucc")
      }
    }
  }
  request.send(encodeForAjax(data))
}

function cancelEditHandler(e) {
  inputs.forEach((field) => {
    if (field.name != '_token')
      field.value = ''
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
