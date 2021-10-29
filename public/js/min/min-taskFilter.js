const taskFilter=document.querySelector("#taskFilter"),tagsSelect=document.querySelector("#tag-selection"),assigneeSelection=document.querySelector("#assignees-selection"),submitFilter=document.querySelector("#filterSubmit");function selection(e){$(e).select2({width:"100%",placeholder:"Search for project tags",allowClear:!0,dropdownParent:$(e).parent()})}function sendGetAjaxRequest(e){let t=new XMLHttpRequest;t.open("GET",e),t.setRequestHeader("Accept","application/json"),t.onreadystatechange=function(){t.readyState===XMLHttpRequest.DONE&&(200===t.status?buildFilteredTasks(t.responseText):console.log("There was an error "+t))},t.send()}function encodeForAjax(e){return Object.keys(e).map(function(t){return encodeURIComponent(t)+"="+encodeURIComponent(e[t])}).join("&")}function buildFilteredTasks(e){const t=document.querySelector("#overview");t.innerHTML="";let n=document.createElement("div");n.innerHTML=JSON.parse(e),Array.from(n.children).forEach(e=>t.append(e)),document.querySelectorAll(".text-bg-check").forEach(e=>checkColor(e)),document.querySelectorAll(".open-task").forEach(e=>{addGetEventListener(e,null,function(t){onModalReceived(t,e)})})}selection(tagsSelect),selection(assigneeSelection),submitFilter.addEventListener("click",function(e){taskFilter.querySelector('button[type="submit"]').click()}),taskFilter.addEventListener("submit",function(e){e.preventDefault();let t={},n=new FormData(taskFilter);n.forEach((e,o)=>{t[o]=n.getAll(o)}),sendGetAjaxRequest(taskFilter.dataset.href+"?"+encodeForAjax(t))});