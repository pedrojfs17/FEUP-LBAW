const usersDiv=document.getElementById("users"),usersSpinner=document.getElementById("usersSpinner");function receivedUsers(e){usersDiv.innerHTML=e,usersSpinner.classList.add("d-none");let t=document.getElementsByClassName("paginator-link");Array.from(t).forEach(e=>e.addEventListener("click",function(){usersDiv.innerHTML="",usersSpinner.classList.remove("d-none"),sendAjaxRequest("GET",e.dataset.href+"&"+getUserActiveFilters(),null,receivedUsers)}));let r=document.getElementsByClassName("remove-button");Array.from(r).forEach(e=>addDeleteEventListener(e,[e.parentElement.parentElement]))}const searchBar=document.getElementById("searchUsers"),searchButton=document.getElementById("button-search-users");searchBar.addEventListener("keyup",function(){usersDiv.innerHTML="",usersSpinner.classList.remove("d-none"),sendAjaxRequest("GET","/profile?query="+searchBar.value.trim()+"&"+getUserActiveFilters(),null,receivedUsers)}),searchButton.addEventListener("click",function(){usersDiv.innerHTML="",usersSpinner.classList.remove("d-none"),sendAjaxRequest("GET","/profile?query="+searchBar.value.trim()+"&"+getUserActiveFilters(),null,receivedUsers)});const userFilter=document.querySelector("#userFilter"),genderSelection=document.querySelector("#genderSelection"),countrySelection=document.querySelector("#countrySelection"),submitFilter=document.querySelector("#userFilterSubmit");function selection(e){$(e).select2({width:"100%",allowClear:!0,dropdownParent:$(e).parent()})}function getUserActiveFilters(){let e={},t=new FormData(userFilter);return t.forEach((r,n)=>{e[n]=t.getAll(n)}),encodeForAjax(e)}selection(genderSelection),selection(countrySelection),submitFilter.addEventListener("click",function(e){userFilter.querySelector('button[type="submit"]').click()}),userFilter.addEventListener("submit",function(e){e.preventDefault(),sendAjaxRequest("GET","/profile?"+getUserActiveFilters(),null,receivedUsers)}),window.onload=function(){sendAjaxRequest("GET","/profile",null,receivedUsers)};