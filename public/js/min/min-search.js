const projectsDiv=document.getElementById("projects"),tasksDiv=document.getElementById("tasks"),usersDiv=document.getElementById("users");function receivedProjects(e){projectsDiv.innerHTML=e}function receivedTasks(e){tasksDiv.innerHTML=e}function receivedUsers(e){usersDiv.innerHTML=e}function sendGetRequest(e){let t=new XMLHttpRequest;t.onreadystatechange=function(){if(t.readyState===XMLHttpRequest.DONE)if(200===t.status){let e=JSON.parse(this.responseText);receivedProjects(e.projects),receivedTasks(e.tasks),receivedUsers(e.users)}else alert("There was an error "+t.status)},t.open("GET",e,!0),t.setRequestHeader("Accept","application/json"),t.send()}const searchBar=document.getElementById("search"),searchButton=document.getElementById("button-search-projects");searchBar.addEventListener("keyup",function(){projectsDiv.innerHTML="",tasksDiv.innerHTML="",usersDiv.innerHTML="",sendGetRequest("api/search?query="+searchBar.value.trim())}),searchButton.addEventListener("click",function(){projectsDiv.innerHTML="",tasksDiv.innerHTML="",usersDiv.innerHTML="",sendGetRequest("api/search?query="+searchBar.value.trim())});