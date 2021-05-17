const modal = document.querySelector('.modal-container')
console.log(modal)

if(modal.children.length>0){
  const taskDelete = document.getElementById('deleteTask')
  taskDelete.addEventListener('click', function (e) {
    sendDeleteAjaxRequest(taskDelete.dataset.href)
  })
}


function sendDeleteAjaxRequest(route) {
  let xhr = new XMLHttpRequest();
  xhr.open("DELETE", route);
  xhr.send();
}
