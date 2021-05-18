function tagEventListener(element) {
  const tagSelections = element.querySelectorAll('.tag-selection')
  const subTaskSelections = element.querySelector('.subtask-selection')


  tagSelections.forEach(selection => {
    $(selection).select2({
      width: '100%',
      allowClear: true,
      dropdownParent: $(selection).parent()
    })
  })

  console.log(subTaskSelections)

  $(subTaskSelections).select2({
      width: '100%',
      allowClear: true,
      dropdownParent: $(subTaskSelections).parent()
    })

  const tagSelect = element.querySelectorAll('.edit-tags')

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
        if(tagForm.dataset.id.includes("SubTask"))
          updateSubTasks(tagForm.dataset.id, JSON.parse(response))
        else
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
}

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

function updateSubTasks(task, subtask) {
  const subTaskDivs = document.querySelectorAll('.' + task)
  subTaskDivs.forEach(subTask => {
    subTask.innerHTML=""
    subtask.forEach(subtask => {
      subTask.innerHTML+='<button type="button" style="background-color: #e7e7e7"\n' +
      '              class="btn text-start subtask-'+subtask.task_status.toLowerCase().replace(' ','-')+'"'+
      '              data-bs-toggle="modal" data-bs-dismiss="modal"\n' +
      '              data-bs-target="#task'+subtask.id+'Modal">'+subtask.name+'</button>'
    })

    subTask.querySelectorAll('*').forEach(element => checkColor(element))
  })
}


