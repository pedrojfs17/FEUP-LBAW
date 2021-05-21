function addEditButtonEventListner(element) {
    const editButtons = element.querySelectorAll('.editButton')
    
    editButtons.forEach(button => {
        button.addEventListener('click', editButtonHandler)
    }); 
}

function editButtonHandler(e) {
    e.target.parentElement.classList.toggle('d-none')
    e.target.form.classList.toggle('d-none')
}