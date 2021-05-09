$('.tag-selection').select2({
  width: '100%'
});

const tagSelect = document.querySelectorAll('.edit-tags')

tagSelect.forEach(select => {
  let selectedTags = select.parentElement.querySelector('select')
  let sel = $(select.parentElement.querySelector('select')).select2('data')
  select.addEventListener('click', function(e) {
    console.log(sel)
    if(!selectedTags.classList.contains('show')) {
      for(let tag in sel) {
        sendPatchAjaxRequest(select.dataset.href, {
          "tag" : tag.id
        }, window[button.dataset.onEdit])
      }

    }
  })
})


function sendPatchAjaxRequest(route, data, successFunction) {
  const xhr = new XMLHttpRequest();
  xhr.open("PATCH", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4) {
      if (successFunction) successFunction(JSON.parse(this.response))
    }
  };

  xhr.send(encodeForAjax(data));
}

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}
