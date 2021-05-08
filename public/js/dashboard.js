const projectsDiv = document.getElementById('projects')
const projectsSpinner = document.getElementById('projectsSpinner')

function receivedProjects(responseText) {
  projectsDiv.innerHTML = JSON.parse(responseText)
  projectsSpinner.classList.add('d-none')

  let paginationLinks = document.getElementsByClassName('paginator-link')
  Array.from(paginationLinks).forEach(link => link.addEventListener('click', function() {
    projectsDiv.innerHTML = ""
    projectsSpinner.classList.remove('d-none')
    sendGetRequest(link.dataset.href);
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
