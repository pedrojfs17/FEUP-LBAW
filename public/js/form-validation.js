const forms = document.querySelectorAll('.validate-form')
forms.forEach(form => {
  form.querySelectorAll('input').forEach(input => {
    input.addEventListener('keyup', function() {
      input.classList.remove('is-invalid')
      input.classList.remove('is-valid')
      form.classList.remove('was-validated')
    })
    input.addEventListener('change', function() {
      input.classList.remove('is-invalid')
      input.classList.remove('is-valid')
      form.classList.remove('was-validated')
    })
  })
})

const resetButtons = document.querySelectorAll('.reset-form-button')
resetButtons.forEach(button => {
  button.addEventListener('click', function() {
    let form = document.querySelector('#' + button.dataset.target)
    form.classList.remove('was-validated')
    form.reset()
  })
})

/* Validate Forms */

function validateRecoverPasswordForm() {
  const form = document.querySelector('#changePassword')
  return validatePassword(form, "#inputPassword", false)
    && validatePassword(form, "#inputNewPassword", true)
}

function validateCreateTaskForm() {
  const form = document.querySelector('#createTaskForm')
  let nameField = form.querySelector('[name="name"]')
  let dateField = form.querySelector('[type="date"]')
  let valid = true
  if (dateField.value !== '') valid = dateAfterToday(form, dateField)
  return fieldNotEmpty(form, nameField) && valid
}

function validateCreateTagForm() {
  const form = document.querySelector('#createTagForm')
  let nameField = form.querySelector('[name="name"]')
  return fieldNotEmpty(form, nameField)
}

/* Validate Helper Functions */

function validatePassword(form, id, withConfirmation, withMin) {
  let passwordInput = form.querySelector(id)
  let valid = true

  if (withConfirmation) {
    let confirmationInput = form.querySelector(id + "Confirmation")
    valid = checkForConfirmationInput(form, passwordInput, confirmationInput, "Passwords must match!")
  }

  if (passwordInput.value.length === 0) {
    valid = false
    passwordInput.setCustomValidity("Please fill out this field!")
    form.querySelector('#' + passwordInput.getAttribute('aria-describedby')).innerText = "Please fill out this field!"
  }

  if (withMin && passwordInput.value.length < 6) {
    valid = false
    passwordInput.setCustomValidity("Password must be at least 6 characters long!")
    form.querySelector('#' + passwordInput.getAttribute('aria-describedby')).innerText = "Password must be at least 6 characters long!"
  }

  return valid
}

function fieldNotEmpty(form, field) {
  if (field.value === '') {
    field.setCustomValidity("Please fill out this field!");
    form.querySelector('#' + field.getAttribute('aria-describedby')).innerText = "Please fill out this field!"
    field.classList.add('is-invalid')
    return false
  }
  return true
}

function dateAfterToday(form, field) {
  let inpDate = new Date(field.value);
  let currDate = new Date();

  if(currDate.getTime() > inpDate.getTime()) {
    field.setCustomValidity("Due date must be after today!");
    form.querySelector('#' + field.getAttribute('aria-describedby')).innerText = "Due date must be after today!"
    field.classList.add('is-invalid')
    return false
  }

  return true
}

function checkForConfirmationInput(form, first, second, message) {
  if (first.value !== second.value) {
    second.setCustomValidity(message);
    form.querySelector('#' + second.getAttribute('aria-describedby')).innerText = message
    second.classList.add('is-invalid')
    return false
  }
  return true
}

function serverSideValidation(form, response) {
  if (!response.errors) return
  Object.keys(response.errors).forEach(input => {
    let inputField = form.querySelector('[name="' + input + '"]')
    inputField.classList.add('is-invalid')
    let inputFeedback = form.querySelector('#' + inputField.getAttribute('aria-describedby'))
    inputFeedback.innerText = response.errors[input][0]
  })
}
