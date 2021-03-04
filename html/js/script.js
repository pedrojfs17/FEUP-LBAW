const myModal = document.getElementById('exampleModal')
const myInput = document.getElementById('myInput')

if (myModal) {
	myModal.addEventListener('shown.bs.modal', function () {
	  myInput.focus()
	})
}

const element = document.querySelector('#aboutPage')

let topPos = null
if(element){
	topPos = element.getBoundingClientRect().top + window.pageYOffset
}
	

const myLearnMore = document.getElementById('learnMore')

if(myLearnMore) {
	myLearnMore.addEventListener("click",function (){
		console.log("bababoey")
		window.scroll({
			top: topPos, // scroll so that the element is at the top of the view
			behavior: 'smooth' // smooth scroll
		})
	})
}
	
