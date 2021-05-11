const tagSelections = document.querySelectorAll('.tag-selection')

tagSelections.forEach(selection => {
  $(selection).select2({
    width: '100%',
    placeholder: 'Search for project tags',
    allowClear: true,
    dropdownParent: $(selection).parent()
  })
})

const tagSelect = document.querySelectorAll('.edit-tags')

tagSelect.forEach(select => {
  let tagForm = select.parentElement.querySelector('form')

  tagForm.addEventListener('submit', function (e) {
    e.preventDefault()
    let object = {}
    let data = new FormData(tagForm)

    data.forEach((value, key) => {
      if (data.getAll(key).length === 1)
        object[key] = value
      else
        object[key] = data.getAll(key)
    })

    let successFunction = function(response) {
      updateTags(tagForm.dataset.id, JSON.parse(response))
    }

    sendPatchAjaxRequest(tagForm.dataset.href, object, successFunction)
  })

  select.addEventListener('click', function (e) {
    if (select.dataset.editing === "false") {
      select.innerHTML = '<i class="bi bi-check2"></i>'
      select.dataset.editing = "true"
    } else {
      select.innerHTML = '<i class="bi bi-pencil"></i>'
      select.dataset.editing = "false"
      tagForm.querySelector('button[type="submit"]').click()
    }
  })
})

function sendPatchAjaxRequest(route, data, successFunction) {
  let xhr = new XMLHttpRequest();
  xhr.open("PATCH", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
      successFunction(this.responseText)
    }
  };

  xhr.send(encodeForAjax(data));
}

function encodeForAjax(data) {
  return Object.keys(data).map(function (k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}


function updateTags(task, tags) {
  const tagDivs = document.querySelectorAll('.' + task)
  tagDivs.forEach(tagDiv => {
    tagDiv.innerHTML=""
    tags.forEach(tag => {
      tagDiv.innerHTML += '<p class="d-inline-block m-0 py-1 px-2 rounded text-bg-check" type="button" style="background-color:' + tag.color + '"> <small>' + tag.name + '</small> </p>'
    })

    tagDiv.querySelectorAll('*').forEach(element => checkColor(element))
  })
}


