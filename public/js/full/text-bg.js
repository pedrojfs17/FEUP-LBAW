const elements = document.querySelectorAll('.text-bg-check')

function checkColor(element) {
  let color = element.style["background-color"]
  color = color.replace(/[^\d,]/g, '').split(',');

  let r = color[0]
  let g = color[1]
  let b = color[2]

  if (r * 0.299 + g * 0.587 + b * 0.114 > 186)
    element.style.color = "#000000"
  else
    element.style.color = "#FFFFFF"
}

elements.forEach(element => checkColor(element))
