function addEditButtonEventListner(element) {
    const editButtons = element.querySelectorAll('.editButton')
    
    editButtons.forEach(button => {
        button.addEventListener('click', editButtonHandler)
    }); 
}

function addCancelButtonEventListner(element) {
    const cancelButtons = element.querySelectorAll('.cancelButton')
    cancelButtons.forEach(button => {
        button.addEventListener('click', cancelButtonHandler)
    })
}

function addSaveButtonEventListner(element) {
    const saveButtons = element.querySelectorAll('.saveButton')
    saveButtons.forEach(button => {
        button.addEventListener('click', saveButtonHandler)
    })
}

function editButtonHandler(e) {
    const button = e.target.closest('.editButton')
    button.parentElement.classList.toggle('d-none')
    button.form.classList.toggle('d-none')
}

function cancelButtonHandler(e) {
    const button = e.target.closest('.cancelButton')
    const info = document.getElementById(button.form.dataset.info)
    const inputs = button.form.elements
    for (input of inputs) {
        if (input.name != '_token')
            input.value = input.placeholder
    }
    info.classList.toggle('d-none')
    button.form.classList.toggle('d-none')
}

function saveButtonHandler(e) {
    const button = e.target.closest('.saveButton')
    const info = document.getElementById(button.form.dataset.info)
    const inputs = button.form.elements
    let data = {}
    for (input of inputs) {
        if (input.value != input.placeholder || input.name === '_token') {
            data[input.name] = input.value
            if (input.name != '_token') {
                input.placeholder = input.value
            }
        }
    }

    if (Object.keys(data).length === 1) return

    sendAjaxRequest('PATCH', button.form.action, encodeForAjax(data), (response) => {onSaveSuccess(button.form.dataset.info, response)})


    info.classList.toggle('d-none')
    button.form.classList.toggle('d-none')
}

function onSaveSuccess(info, response) {
    updateCard(response['taskID'], response['taskCard'])
    updateTaskModal('tasks' + response['taskID'] + 'ModalLabel', response['breadcrumbChanges'])
    updateTaskModal(info, response['modalChanges'])
    let modal_elem = document.getElementById('task' + response['taskID'] + 'Modal')
    addModalEventListeners(modal_elem)
}
