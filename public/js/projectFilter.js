const projectFilter = document.querySelector('#projectFilter')
const tagsSelect = document.querySelector('#completion-selection')
const submitFilter = document.querySelector('#projectFilterSubmit')

console.log(projectFilter)

submitFilter.addEventListener('click', function (e) {
  projectFilter.querySelector('button[type="submit"]').click()
})

projectFilter.addEventListener('submit', function (e) {
  e.preventDefault()
  let object = {}
  let data = new FormData(projectFilter)

  data.forEach((value, key) => {
    object[key] = data.getAll(key)
  })
  sendGetAjaxRequest(projectFilter.dataset.href + '?' + encodeForAjax(object))
})

function sendGetAjaxRequest(route) {
  let xhr = new XMLHttpRequest();
  xhr.open("GET", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        buildFilteredTasks(xhr.responseText)
      }
      else {
        console.log('There was an error ' + xhr);
      }
    }
  }
  xhr.send();
}

function encodeForAjax(data) {
  return Object.keys(data).map(function (k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}

function buildFilteredTasks(responseText) {
  const div = document.querySelector('#projects')
  div.innerHTML = ""

  let elem = document.createElement('div')
  elem.innerHTML = JSON.parse(responseText)


  Array.from(elem.children).forEach(element => div.append(element))

  let paginationLinks = document.getElementsByClassName('paginator-link')
  Array.from(paginationLinks).forEach(link => link.addEventListener('click', function() {
    projectsDiv.innerHTML = ""
    projectsSpinner.classList.remove('d-none')
    sendGetRequest(link.dataset.href);
  }))

}
