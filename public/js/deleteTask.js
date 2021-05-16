const taskDelete = document.querySelector('#taskDelete')
console.log(taskDelete)
taskDelete.addEventListener('click', function (e) {
  sendDeleteAjaxRequest(taskDelete.dataset.href)
})

function sendDeleteAjaxRequest(route) {

  let xhr = new XMLHttpRequest();
  xhr.open("DELETE", route);
  xhr.send();
}
