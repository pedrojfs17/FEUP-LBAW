const projectsRequest = new XMLHttpRequest()

const closedDiv = document.getElementById('closed-projects')
const openDiv = document.getElementById('open-projects')

projectsRequest.onreadystatechange = function() {
  if (projectsRequest.readyState === XMLHttpRequest.DONE) {
    if (projectsRequest.status === 200) {
      let projects = JSON.parse(projectsRequest.responseText)
      let openProjects = projects.open
      let closedProjects = projects.closed

      openProjects.forEach(project => {
        openDiv.innerHTML += project
      })

      closedProjects.forEach(project => {
        closedDiv.innerHTML += project
      })
    }
    else {
      alert('There was an error ' + projectsRequest.status);
    }
  }
}

projectsRequest.open("GET", "api/project", true)
projectsRequest.setRequestHeader("Accept", "application/json")
projectsRequest.send()
