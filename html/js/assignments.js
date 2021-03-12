const members = document.querySelectorAll('.carousel-item .card-header')

members.forEach(member => {
    let color = member.style["background-color"]
    color = color.replace(/[^\d,]/g, '').split(',');

    let r = color[0]
    let g = color[1]
    let b = color[2]

    if (r * 0.299 + g * 0.587 + b * 0.114 > 186)
        member.style.color = "#000000" 
    else 
        member.style.color = "#FFFFFF" 
})