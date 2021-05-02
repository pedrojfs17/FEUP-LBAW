let current = 1;

const fieldsets = document.querySelectorAll('fieldset')
const nextButtons = document.querySelectorAll('.next')
const previousButtons = document.querySelectorAll('.previous')

const progressBar = document.getElementById('ms-form-progress-bar')
const progressBarItems = document.getElementById('progressbar').querySelectorAll('button')

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

function nextFieldset() {
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

	