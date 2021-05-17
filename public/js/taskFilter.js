const taskFilter = document.querySelector('#taskFilter')
const tagsSelect = document.querySelector('#tag-selection')
const assigneeSelection = document.querySelector('#assignees-selection')
const submitFilter = document.querySelector('#filterSubmit')

function selection(form) {
  $(form).select2({
    width: '100%',
    placeholder: 'Search for project tags',
    allowClear: true,
    dropdownParent: $(form).parent()
  })
}

selection(tagsSelect)
selection(assigneeSelection)

submitFilter.addEventListener('click', function (e) {
  taskFilter.querySelector('button[type="submit"]').click()
})

taskFilter.addEventListener('submit', function (e) {
  e.preventDefault()
  let object = {}
  let data = new FormData(taskFilter)

  data.forEach((value, key) => {
    object[key] = data.getAll(key)
  })
  sendGetAjaxRequest(taskFilter.dataset.href + '?' + encodeForAjax(object))
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
  const div = document.querySelector('#overview')
  div.innerHTML = ""

  let elem = document.createElement('div')
  elem.innerHTML = JSON.parse(responseText)


  Array.from(elem.children).forEach(element => div.append(element))

  const openTaskButtons = document.querySelectorAll('.open-task')

  openTaskButtons.forEach(button => {
    let callback = function(responseText) {
      onModalReceived(responseText, button)
    }
    addGetEventListener(button, null, callback)
  })

}




