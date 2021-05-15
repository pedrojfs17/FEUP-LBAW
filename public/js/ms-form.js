let current = 1

const fieldsets = document.querySelectorAll('fieldset')
const nextButtons = document.querySelectorAll('.next')
const previousButtons = document.querySelectorAll('.previous')

const progressBar = document.getElementById('ms-form-progress-bar')
const progressBarItems = document.getElementById('progressbar').querySelectorAll('.progress-item ')

const steps = fieldsets.length;

setProgressBar(current);

progressBarItems.forEach((button, index) => button.addEventListener('click', function() {
	const field = index + 1

	while(current != field) {
		if (current > index)
			previousFieldset()
		else
			nextFieldset()
	}
}))

nextButtons.forEach(button => button.addEventListener('click', nextFieldset))

previousButtons.forEach(button => button.addEventListener('click', previousFieldset))

const inputs = document.querySelectorAll('fieldset input')
const textareas = document.querySelectorAll('fieldset textarea')

inputs.forEach(input => input.addEventListener('change', function () { checkMissing(input) }))
textareas.forEach(textarea => textarea.addEventListener('change', function () { checkMissing(textarea) }))

const closeButton = document.querySelectorAll('#createProjectModal .btn-close')[0]
closeButton.addEventListener('click', function() {
  let form = document.getElementById('msform')
  form.reset()
  inputs.forEach(input => input.classList.remove('invalid-input'))
  textareas.forEach(textarea => textarea.classList.remove('invalid-input'))
  current = 1
})

function checkMissing(field) {
  if (field.value == null || String(field.value).valueOf() === String("").valueOf())
    field.classList.add('invalid-input')
  else
    field.classList.remove('invalid-input')
}

function missingInput(fields) {
  let missing = false
  for (let i = 0; i < fields.length; i++) {
    if (fields[i].value == null || String(fields[i].value).valueOf() === String("").valueOf()) {
      fields[i].classList.add('invalid-input')
      missing = true
    }
  }
  return missing
}

function nextFieldset() {
  let inputs = fieldsets[current - 1].querySelectorAll('input')
  let textareas = fieldsets[current - 1].querySelectorAll('textarea')

  if (missingInput(inputs) || missingInput(textareas))
    return

	const currentFieldset = current
	const nextFieldset = current + 1

	progressBarItems[nextFieldset - 1].classList.add('active')

	fieldsets[nextFieldset - 1].style.display = 'block'

	fieldsets[currentFieldset - 1].animate([
		{ opacity: 1, },
		{ opacity: 0, }
	], 500)

	fieldsets[nextFieldset - 1].animate([
		{ opacity: 0, },
		{ opacity: 1, }
	], 500)

	fieldsets[currentFieldset - 1].style.display = 'none'

	setProgressBar(++current);
}

function previousFieldset() {
	const currentFieldset = current
	const previousFieldset = current - 1

	progressBarItems[currentFieldset - 1].classList.remove('active')

	fieldsets[previousFieldset - 1].style.display = 'block'

	fieldsets[currentFieldset - 1].animate([
		{ opacity: 1, },
		{ opacity: 0, }
	], 500)

	fieldsets[previousFieldset - 1].animate([
		{ opacity: 0, },
		{ opacity: 1, }
	], 500)


	fieldsets[currentFieldset - 1].style.display = 'none'

	setProgressBar(--current);
}

function setProgressBar(curStep) {
	var percent = parseFloat(100 / (steps - 1)) * (curStep - 1);
	percent = percent.toFixed();
	progressBar.style.width = percent + "%"
}


