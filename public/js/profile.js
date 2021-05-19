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
  e.target.style.display = 'none'
}

function saveEditHandler(e) {
  console.log("Guardadah")
}

function cancelEditHandler(e) {
  Object.keys(values).forEach(function (field) {

  })
  console.log("Canceladah")
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
