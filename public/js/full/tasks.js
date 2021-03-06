function taskEventListener(element) {
  const tagSelections = element.querySelectorAll('.tag-selection')
  const subTaskSelections = element.querySelector('.subtask-selection')
  const waitingSelection = element.querySelector('.waiting-selection')
  const assignmentsSelection = element.querySelector('.assign-selection')
  const editButtons = element.querySelectorAll('.edit-task')
  const checklistItem = element.querySelectorAll('.checklist-item')

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

  addInputEventListener()

  checklistItem.forEach(item => {
    addCheckListItems(item)
  })


  editButtons.forEach(select => {
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
        updateCard(msg['taskID'], msg['taskCard'])
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

  initializeTooltips()
  initializePopovers()
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
  const cardDiv = document.querySelector('#task-' + taskID)
  if (!cardDiv) return;

  cardDiv.innerHTML = ""
  let newElem = document.createElement('div')
  newElem.innerHTML = card
  let updatedCard = newElem.children[0]
  parentDiv.insertBefore(updatedCard, cardDiv)
  cardDiv.remove()

  const updatedCardButton = document.querySelector('#task-' + taskID).querySelector('.open-task')
  addGetEventListener(updatedCardButton, null, onModalReceived)

  updatedCard.querySelectorAll('.text-bg-check').forEach(element => checkColor(element))
}


function addCheckListItems(item) {
  let deleteBtns = item.querySelectorAll('.delete-item')
  let checkItems = item.querySelectorAll('.form-check-input')
  let successFunction = function (response) {
    updateCard(response['taskID'], response['taskCard'])
    updateTaskModal(item.dataset.id, response['modalChanges'])
    const selectItems = document.querySelectorAll('.checklist-item')
    addInputEventListener()
    selectItems.forEach(updatedItem => {
      addCheckListItems(updatedItem)
    })
  }

  deleteBtns.forEach(button => button.addEventListener('click', () => {
    sendAjaxRequest('DELETE', item.dataset.href, encodeForAjax({_token: csrfToken}), successFunction)
  }))

  checkItems.forEach(checkItem => checkItem.addEventListener('click', () => {
    sendAjaxRequest('PATCH', item.dataset.href, encodeForAjax({
      completed: checkItem.checked,
      _token: csrfToken
    }), successFunction)
  }))
}

function addInputEventListener() {
  const checklistForm = document.querySelector('#addItem')
  if (!checklistForm) return;

  const newItemInput = checklistForm.querySelector('input[name="new_item"]')

  newItemInput.addEventListener('keypress', function (event) {
    let form = newItemInput.parentElement.parentElement
    form.addEventListener('submit', (e) => {
      e.preventDefault()
    })
    let successFunction = function (response) {
      updateCard(response['taskID'], response['taskCard'])
      updateTaskModal(form.dataset.id, response['modalChanges'])
      const selectItems = document.querySelectorAll('.checklist-item')
      addInputEventListener()
      selectItems.forEach(updatedItem => {
        addCheckListItems(updatedItem)
      })
    }
    if (event.key === 'Enter') {
      sendAjaxRequest('POST', checklistForm.dataset.href, encodeForAjax({
        new_item: newItemInput.value,
        _token: csrfToken
      }), successFunction)
      form.reset()
    }
  })
}

function updateTaskModal(changeID, changeHTML) {
  let old_elem = document.getElementById(changeID)
  let new_elem = document.createRange().createContextualFragment(changeHTML).firstChild
  new_elem.querySelectorAll('.text-bg-check').forEach(element => checkColor(element))
  old_elem.parentElement.replaceChild(new_elem, old_elem)
}
