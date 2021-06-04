const usersDiv = document.getElementById('users')
const usersSpinner = document.getElementById('usersSpinner')

function receivedUsers(responseText) {
  usersDiv.innerHTML = responseText
  usersSpinner.classList.add('d-none')

  let paginationLinks = document.getElementsByClassName('paginator-link')
  Array.from(paginationLinks).forEach(link => link.addEventListener('click', function() {
    usersDiv.innerHTML = ""
    usersSpinner.classList.remove('d-none')
    sendAjaxRequest("GET", link.dataset.href + "&" + getUserActiveFilters(), null, receivedUsers)
  }))

  let removeButtons = document.getElementsByClassName('remove-button')
  Array.from(removeButtons).forEach(button => addDeleteEventListener(button, [button.parentElement.parentElement]))
}

const searchBar = document.getElementById('searchUsers')
const searchButton = document.getElementById('button-search-users')

searchBar.addEventListener('keyup', function () {
  usersDiv.innerHTML = ""
  usersSpinner.classList.remove('d-none')
  sendAjaxRequest("GET", "/profile?query=" + searchBar.value.trim() + "&" + getUserActiveFilters(), null, receivedUsers)
})

searchButton.addEventListener('click', function () {
  usersDiv.innerHTML = ""
  usersSpinner.classList.remove('d-none')
  sendAjaxRequest("GET", "/profile?query=" + searchBar.value.trim() + "&" + getUserActiveFilters(), null, receivedUsers)
})

const userFilter = document.querySelector('#userFilter')
const genderSelection = document.querySelector('#genderSelection')
const countrySelection = document.querySelector('#countrySelection')
const submitFilter = document.querySelector('#userFilterSubmit')

function selection(form) {
  $(form).select2({
    width: '100%',
    allowClear: true,
    dropdownParent: $(form).parent()
  })
}

selection(genderSelection)
selection(countrySelection)

submitFilter.addEventListener('click', function (e) {
  userFilter.querySelector('button[type="submit"]').click()
})

userFilter.addEventListener('submit', function (e) {
  e.preventDefault()
  sendAjaxRequest("GET", "/profile?" + getUserActiveFilters(), null, receivedUsers)
})

function getUserActiveFilters() {
  let object = {}
  let data = new FormData(userFilter)

  data.forEach((value, key) => {
    object[key] = data.getAll(key)
  })

  return encodeForAjax(object);
}

window.onload = function () {
  sendAjaxRequest("GET", "/profile", null, receivedUsers)
}
