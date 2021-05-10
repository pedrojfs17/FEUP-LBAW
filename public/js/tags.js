$('.tag-selection').select2({
  width: '100%'
});

const tagSelect = document.querySelectorAll('.edit-tags')
const csrfToken = document.querySelector('input[name="_token"]').value



tagSelect.forEach(select => {
  let tagForm = select.parentElement.querySelector('form')
  let show = false;
  const click = new CustomEvent('submit');
  select.addEventListener('click', function(e) {
    show = !show
    if(!show) {
      tagForm.dispatchEvent(click)
      /*
      sel.forEach(tag => {

        sendPatchAjaxRequest(select.dataset.href, {
          "tag" : tag.id,
          "_token": csrfToken,
        })
      })*/
    }
  })
  tagForm.addEventListener('submit',(e)=>{
    e.preventDefault()
    let object = {}
    let i=0;
    let data = new FormData(tagForm)

    data.forEach((value, key) => {
      if(data.getAll(key).length===1)
        object[key]=value
      else
        object[key]=data.getAll(key)
    })

    sendPatchAjaxRequest(tagForm.action, object)


  } )
})

function sendPatchAjaxRequest(route, data) {
  const xhr = new XMLHttpRequest();
  xhr.open("PATCH", route);
  xhr.setRequestHeader("Accept", "application/json");
  xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  xhr.send(encodeForAjax(data));
}

function encodeForAjax(data) {
  return Object.keys(data).map(function(k) {
    return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
  }).join('&')
}
