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

// $('.carousel .carousel-item').each(function(){
//     var minPerSlide = 3;
//     var next = $(this).next();
//     if (!next.length) {
//     next = $(this).siblings(':first');
//     }
//     next.children(':first-child').clone().appendTo($(this));
    
//     for (var i=0;i<minPerSlide;i++) {
//         next=next.next();
//         if (!next.length) {
//             next = $(this).siblings(':first');
//         }
        
//         next.children(':first-child').clone().appendTo($(this));
//     }
// });