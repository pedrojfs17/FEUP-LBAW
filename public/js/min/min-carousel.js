const carouselItems=document.querySelectorAll(".carousel .carousel-item");carouselItems.forEach(e=>{let l=e.nextElementSibling;l||(l=e.parentNode.firstElementChild),e.appendChild(l.firstElementChild.cloneNode(!0));for(let t=1;t<3;t++)(l=l.nextElementSibling)||(l=e.parentNode.firstElementChild),e.appendChild(l.firstElementChild.cloneNode(!0))});
