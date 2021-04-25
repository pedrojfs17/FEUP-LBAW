const myModal = document.getElementById('exampleModal')
const myInput = document.getElementById('myInput')

if (myModal) {
	myModal.addEventListener('shown.bs.modal', function () {
	  myInput.focus()
	})
}

const navbar = document.getElementById("navbar")

if (navbar) {
	const navbar_toggler = document.getElementById("navToggler")
	navbar_toggler.addEventListener("click", function (){
		navbar.classList.toggle('opaque')
	})

	let prevScrollpos = window.pageYOffset
	window.addEventListener("scroll", function (){
		let currentScrollPos = window.pageYOffset
		if (prevScrollpos > currentScrollPos) {
			navbar.style.transform = "translateY(0)";
		} else {
			navbar.style.transform = "translateY(-100%)";
		}
		prevScrollpos = currentScrollPos;
	})
}


