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
    console.log(value, key)
    object[key] = data.getAll(key)
  })
  console.log(object)
  sendPatchAjaxRequest(taskFilter.dataset.href+'?'+encodeForAjax(object))
})

function sendPatchAjaxRequest(route) {
  let xhr = new XMLHttpRequest();
  xhr.open("GET", route);
  xhr.setRequestHeader("Accept", "application/json");

  xhr.send();
}

function encodeForAjax(data) {
  return Object.keys(data).map(function (k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}


