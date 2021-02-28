const myModal = document.getElementById('exampleModal')
const myInput = document.getElementById('myInput')

if (myModal) {
	myModal.addEventListener('shown.bs.modal', function () {
	  myInput.focus()
	})
}
