const carouselItems = document.querySelectorAll('.carousel .carousel-item')

carouselItems.forEach(item => {
    let minPerSlide = 3
    let next = item.nextElementSibling

    console.log(next)
    if (!next) {
        next = item.parentNode.firstElementChild;
    }
    console.log(next)
    item.appendChild(next.firstElementChild.cloneNode(true))

    for (let i = 1; i < minPerSlide; i++) {
        next = next.nextElementSibling

        if (!next) {
            next = item.parentNode.firstElementChild;
        }
        
        item.appendChild(next.firstElementChild.cloneNode(true))
    }
})
