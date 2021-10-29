const items=document.querySelectorAll(".draggable"),taskGroups=document.querySelectorAll(".task-group");function handleDrag(){this.classList.add("is-moving")}function handleDrop(e){let t=e.dataTransfer.getData("text"),n=document.getElementById(t);const a=new XMLHttpRequest;a.open("PATCH",e.currentTarget.dataset.href+n.dataset.id),a.setRequestHeader("Content-Type","application/x-www-form-urlencoded"),a.send(encodeForAjax({task_status:e.currentTarget.dataset.status,_token:document.querySelector('input[name="_token"]').value}))}function encodeForAjax(e){return Object.keys(e).map(function(t){return encodeURIComponent(t)+"="+encodeURIComponent(e[t])}).join("&")}function handleHover(e){e.preventDefault();let t,n=e.dataTransfer.getData("text"),a=document.getElementById(n),r=e.clientY,d=this.querySelectorAll(".draggable");for(let e of d){if(r<e.getBoundingClientRect().y+e.getBoundingClientRect().height/2)break;t=e}t?t.insertAdjacentElement("afterend",a):this.querySelector(".d-grid").insertAdjacentElement("afterbegin",a)}function handleDragStart(e){e.dataTransfer.effectAllowed="move",e.dataTransfer.setData("text",this.id)}function handleDragEnd(e){this.classList.remove("is-moving"),window.setTimeout(function(){e.target.classList.add("is-moved"),window.setTimeout(function(){e.target.classList.remove("is-moved")},1e3)},100)}items.forEach(function(e){e.addEventListener("drag",handleDrag,!1),e.addEventListener("dragstart",handleDragStart,!1),e.addEventListener("dragend",handleDragEnd,!1)}),taskGroups.forEach(function(e){e.addEventListener("drop",handleHover),e.addEventListener("drop",handleDrop),e.addEventListener("dragover",handleHover)});