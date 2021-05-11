$('.tag-selection').select2({
  width: '100%'
});

const tagSelect = document.querySelectorAll('.edit-tags')
const csrfToken = document.querySelector('input[name="_token"]').value



tagSelect.forEach(select => {
  let tagForm = select.parentElement.querySelector('form')

  tagForm.addEventListener('submit', function (e) {
    e.preventDefault()
    let object = {}
    let data = new FormData(tagForm)

    data.forEach((value, key) => {
      if (data.getAll(key).length === 1)
        object[key] = value
      else
        object[key] = data.getAll(key)
    })

    let successFunction = function(response) {
      updateTags(tagForm.dataset.id, JSON.parse(response))
    }

    sendPatchAjaxRequest(tagForm.dataset.href, object, successFunction)
  })

  let show = false;
  const click = new CustomEvent('submit');
  select.addEventListener('click', function(e) {
    show = !show
    if (!show) tagForm.querySelector('button[type="submit"]').click()
  })
})

function sendPatchAjaxRequest(route, data, successFunction) {
  let xhr = new XMLHttpRequest();
  xhr.open("PATCH", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
      successFunction(this.responseText)
    }
  };

  xhr.send(encodeForAjax(data));
}

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}
