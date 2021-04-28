function buildProjectElement(project) {
  const div = document.getElementById('projects')

  let card = document.createElement('div')
  card.role = "button"
  card.className = "card my-2"
  card.innerHTML =
    '<div class="card-body">\n' +
    '  <h5 class="card-title"><a class="stretched-link text-decoration-none text-reset" href="project/' + project.id + '/overview">' + project.name + '</a></h5>\n' +
    '  <div class="row align-items-center">\n' +
    '    <div class="col-lg-3 col-md-3">\n' +
    '      <ul class="avatar-overlap d-none d-md-block">\n' +
    '        <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>\n' +
    '        <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>\n' +
    '        <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>\n' +
    '      </ul>\n' +
    '    </div>\n' +
    '    <div class="col-lg-3 col-md-3 text-muted">' + ( project.due_date != null ? 'Due Date: ' + (new Date(Date.parse(project.due_date))).toDateString() : '') + '</div>\n' +
    '    <div class="col-lg-4 offset-lg-2 col-md-4 offset-md-2 text-end text-muted">\n' +
    '      Progress\n' +
    '      <div class="progress">\n' +
    '        <div class="progress-bar bg-success" role="progressbar" style="width: 25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">25%</div>\n' +
    '      </div>\n' +
    '    </div>\n' +
    '  </div>\n' +
    '</div>'

  div.append(card);
}

const projectsRequest = new XMLHttpRequest()

projectsRequest.onreadystatechange = function() {
  if (projectsRequest.readyState === XMLHttpRequest.DONE) {
    if (projectsRequest.status === 200) {
      let projects = JSON.parse(projectsRequest.responseText)
      projects.forEach(project => {
        buildProjectElement(project);
      })
    }
    else {
      alert('There was an error ' + projectsRequest.status);
    }
  }
}

projectsRequest.open("GET", "api/project", true)
projectsRequest.send()
