/* AJAX FUNCTIONS */

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}

function sendAjaxRequest(method, url, data, callback) {
  let request = new XMLHttpRequest()

  request.onreadystatechange = function() {
    if (request.readyState === XMLHttpRequest.DONE) {
      if (request.status === 200) {
        if (callback) callback(this.responseText)
      }
      else {
        console.log('There was an error ' + request);
      }
    }
  }

  request.open(method, url, true)
  request.setRequestHeader("Accept", "application/json")
  if (method === "POST" || method === "PATCH")
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  request.send(data)
}

/* CREATE FORMS */

const createForms = document.querySelectorAll('.create-form')

function addTagElement(responseText) {
  const tagsSection = document.getElementById('project-tags')
  const tag = JSON.parse(responseText)
  tagsSection.innerHTML +=
    ' <p class="d-inline-block m-0 my-1 py-1 px-3 px-sm-2 rounded text-bg-check" type="button" style="background-color: ' + tag.color + '">\n' +
    '   <small class="d-none d-sm-inline-block">' + tag.name + '</small>\n' +
    ' </p> '
}

createForms.forEach(form => {
  form.addEventListener('submit', function(e) {
    e.preventDefault()
    let object = {};
    new FormData(form).forEach((value, key) => object[key] = value);
    sendAjaxRequest("POST", form.dataset.href, encodeForAjax(object), window[form.dataset.onSubmit])
  })
})

