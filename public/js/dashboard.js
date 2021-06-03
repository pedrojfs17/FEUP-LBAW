const projectsDiv = document.getElementById('projects')
const projectsSpinner = document.getElementById('projectsSpinner')

function receivedProjects(responseText) {
  projectsDiv.innerHTML = JSON.parse(responseText)
  projectsSpinner.classList.add('d-none')

  let paginationLinks = document.getElementsByClassName('paginator-link')
  Array.from(paginationLinks).forEach(link => link.addEventListener('click', function() {
    projectsDiv.innerHTML = ""
    projectsSpinner.classList.remove('d-none')
    sendGetRequest(link.dataset.href + "&" + encodeForAjax(getProjectActiveFilters()));
  }))
}

function sendGetRequest(url) {
  let projectsRequest = new XMLHttpRequest()

  projectsRequest.onreadystatechange = function() {
    if (projectsRequest.readyState === XMLHttpRequest.DONE) {
      if (projectsRequest.status === 200) {
        receivedProjects(this.responseText)
      }
      else {
        alert('There was an error ' + projectsRequest.status);
      }
    }
  }

  projectsRequest.open("GET", url, true)
  projectsRequest.setRequestHeader("Accept", "application/json")
  projectsRequest.send()
}

const searchBar = document.getElementById('searchProjects')
const searchButton = document.getElementById('button-search-projects')

searchBar.addEventListener('keyup', function () {
  projectsDiv.innerHTML = ""
  projectsSpinner.classList.remove('d-none')
  sendGetRequest("api/project?query=" + searchBar.value.trim());
})

searchButton.addEventListener('click', function () {
  projectsDiv.innerHTML = ""
  projectsSpinner.classList.remove('d-none')
  sendGetRequest("api/project?query=" + searchBar.value.trim());
})

window.onload = function () {
  sendGetRequest("api/project");
}

const membersSearchBar = document.getElementById('searchMembers')
const membersSearchButton = document.getElementById('button-search-members')
const membersDiv = document.getElementById('members')
const membersSpinner = document.getElementById('membersSpinner')
const selectedMembers = document.getElementById('selected-members')
const addedMembers = document.getElementById('added-members')

membersSearchBar.addEventListener('keyup', function () {
  membersDiv.innerHTML = ""
  membersSpinner.classList.remove('d-none')
  sendGetMembersRequest("/profile?query=" + membersSearchBar.value.trim());
})

membersSearchButton.addEventListener('click', function () {
  membersDiv.innerHTML = ""
  membersSpinner.classList.remove('d-none')
  sendGetMembersRequest("/profile?query=" + membersSearchBar.value.trim());
})

let selectedIds = []

function receivedMembers(responseText) {
  membersDiv.innerHTML = JSON.parse(responseText)
  membersSpinner.classList.add('d-none')

  let addButtons = document.querySelectorAll('.add-member-btn')
  addButtons.forEach(function (btn) {
    if (selectedIds.includes(btn.dataset.id)) {
      btn.style.visibility = 'hidden'
    }
    btn.addEventListener('click', function () {
      console.log("oi")
      selectedMembers.innerHTML += '<option value="' + btn.dataset.id + '" selected></option>'
      selectedIds.push(btn.dataset.id)

      let memberCard = btn.parentElement.parentElement.cloneNode(true)
      let removeButton = memberCard.querySelector('button')
      removeButton.classList.remove('add-member-btn')
      removeButton.classList.add('remove-member-btn')
      removeButton.innerHTML = "Remove"

      if (addedMembers.firstElementChild.classList.contains('text-muted'))
        addedMembers.innerHTML = ""

      addedMembers.appendChild(memberCard)
      removeButton.addEventListener('click', function () {
        let removed = selectedMembers.querySelector('option[value="' + removeButton.dataset.id + '"]')
        selectedMembers.removeChild(removed)
        addedMembers.removeChild(removeButton.parentElement.parentElement)
        if (addedMembers.innerHTML === "")
          addedMembers.innerHTML = "<p class='text-muted'>No members added!</p>"
        let addButton = document.querySelector('.add-member-btn[data-id="' + removeButton.dataset.id + '"]')
        if(addButton != null)
          addButton.style.visibility = 'visible'
        selectedIds.splice(selectedIds.indexOf(removeButton.dataset.id))
      })
      btn.style.visibility = 'hidden'
    })
  })

  let paginationLinks = document.getElementsByClassName('paginator-link')
  Array.from(paginationLinks).forEach(link => link.addEventListener('click', function() {
    membersDiv.innerHTML = ""
    membersSpinner.classList.remove('d-none')
    sendGetMembersRequest(link.dataset.href);
  }))
}

function sendGetMembersRequest(url) {
  let membersRequest = new XMLHttpRequest()

  membersRequest.onreadystatechange = function() {
    if (membersRequest.readyState === XMLHttpRequest.DONE) {
      if (membersRequest.status === 200) {
        receivedMembers(this.responseText)
      }
      else {
        alert('There was an error ' + membersRequest.status);
      }
    }
  }

  membersRequest.open("GET", url, true)
  membersRequest.setRequestHeader("Accept", "application/json")
  membersRequest.send()
}
