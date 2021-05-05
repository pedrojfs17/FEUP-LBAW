const closedDiv = document.getElementById('closed-projects')
const openDiv = document.getElementById('open-projects')

function receivedProjects(responseText) {
  let projects = JSON.parse(responseText)
  let openProjects = projects.open
  let closedProjects = projects.closed

  openProjects.forEach(project => {
    openDiv.innerHTML += project
  })

  closedProjects.forEach(project => {
    closedDiv.innerHTML += project
  })
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
  closedDiv.innerHTML = ""
  openDiv.innerHTML = ""
  sendGetRequest("api/project?query=" + searchBar.value.trim());
})

searchButton.addEventListener('click', function () {
  closedDiv.innerHTML = ""
  openDiv.innerHTML = ""
  sendGetRequest("api/project?query=" + searchBar.value.trim());
})

window.onload = function () {
  sendGetRequest("api/project");
}
