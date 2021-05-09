const projectsDiv = document.getElementById('projects')
const tasksDiv = document.getElementById('tasks')
const usersDiv = document.getElementById('users')

function receivedProjects(responseText) {
  projectsDiv.innerHTML = responseText
}

function receivedTasks(responseText) {
  tasksDiv.innerHTML = responseText
}

function receivedUsers(responseText) {
  usersDiv.innerHTML = responseText
}

function sendGetRequest(url) {
  let request = new XMLHttpRequest()

  request.onreadystatechange = function() {
    if (request.readyState === XMLHttpRequest.DONE) {
      if (request.status === 200) {
        let response = JSON.parse(this.responseText)
        receivedProjects(response.projects)
        receivedTasks(response.tasks)
        receivedUsers(response.users)
      }
      else {
        alert('There was an error ' + request.status);
      }
    }
  }

  request.open("GET", url, true)
  request.setRequestHeader("Accept", "application/json")
  request.send()
}

const searchBar = document.getElementById('search')
const searchButton = document.getElementById('button-search-projects')

searchButton.addEventListener('click', function () {
  console.log(searchBar)
  projectsDiv.innerHTML = ""
  tasksDiv.innerHTML = ""
  usersDiv.innerHTML = ""
  sendGetRequest("api/search?query=" + searchBar.value.trim());
})
