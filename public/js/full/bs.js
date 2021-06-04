function initializeToasts() {
  let toastElList = [].slice.call(document.querySelectorAll('.toast'))
  let toastList = toastElList.map(function (toastEl) {
    return new bootstrap.Toast(toastEl)
  })
  toastList.forEach(toast => toast.show())
}

function initializeTooltips() {
  let tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  let tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })
}
function initializePopovers() {
  let popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  let popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    if (popoverTriggerEl.dataset.bsTrigger)
      return new bootstrap.Popover(popoverTriggerEl, { trigger: popoverTriggerEl.dataset.bsTrigger, html: true })
    else
      return new bootstrap.Popover(popoverTriggerEl)
  })
}


initializeToasts()
initializeTooltips()
initializePopovers()
