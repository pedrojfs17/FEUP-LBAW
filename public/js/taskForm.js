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
        input.disabled = true
    }

    if (Object.keys(data).length === 1) return

    sendAjaxRequest('PATCH', button.form.action, encodeForAjax(data), onSaveSuccess)


    info.classList.toggle('d-none')
    button.form.classList.toggle('d-none')
}

function onSaveSuccess(response) {
    console.log('updating')
    // updateCard(response['id'], response['taskCard'])
    updateModal(response['taskID'], response['taskModal'])
}

function updateModal(taskID, new_modal) {
    let old_modal = document.getElementById('task' + taskID + 'Modal')
    let modalElement = document.createRange().createContextualFragment(new_modal)
    console.log(modalElement.firstChild.children[0])
    old_modal.textContent = ''
    old_modal.append(modalElement.firstChild.children[0])
    // old_modal.parentElement.appendChild()
    // old_modal.remove()
    // old_modal.innerHTML = new_modal
    addModalEventListeners(old_modal)
}