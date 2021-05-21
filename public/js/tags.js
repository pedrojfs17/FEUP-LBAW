function tagEventListener(element) {
  const tagSelections = element.querySelectorAll('.tag-selection')
  const subTaskSelections = element.querySelector('.subtask-selection')
  const waitingSelection = element.querySelector('.waiting-selection')
  const assignmentsSelection = element.querySelector('.assign-selection')


  tagSelections.forEach(selection => {
    $(selection).select2({
      width: '100%',
      allowClear: true,
      dropdownParent: $(selection).parent()
    })
  })

  $(subTaskSelections).select2({
    width: '100%',
    allowClear: true,
    dropdownParent: $(subTaskSelections).parent()
  })

  $(waitingSelection).select2({
    width: '100%',
    allowClear: true,
    dropdownParent: $(waitingSelection).parent()
  })
  $(assignmentsSelection).select2({
    width: '100%',
    allowClear: true,
    dropdownParent: $(assignmentsSelection).parent()
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

      let successFunction = function (response) {
        let msg = JSON.parse(response)
        console.log(msg)
        updateCard(msg['taskID'],msg['taskCard'])
        updateTaskModal(tagForm.dataset.id, msg['modalChanges'])
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


function updateCard(taskID, card) {
  const parentDiv = document.querySelector('#overview')
  const cardDiv = document.querySelector('#task-'+taskID)
  cardDiv.innerHTML=""
  let newElem = document.createElement('div')
  newElem.innerHTML = card
  parentDiv.insertBefore(newElem.children[0],cardDiv)
  cardDiv.remove()
  const updatedCard = document.querySelector('#task-'+taskID).querySelector('.open-task')
  addCardEventListener(updatedCard)
}

function updateTaskModal(task, modalElement) {
  const subTaskDiv = document.querySelector('#' + task)
  subTaskDiv.innerHTML = modalElement
  subTaskDiv.querySelectorAll('*').forEach(element => checkColor(element))
}


