const editProfileButton=document.getElementById("editProfile"),saveEditButton=document.getElementById("saveEdit"),cancelEditButton=document.getElementById("cancelEdit"),actions=document.getElementById("editActions"),inputs=document.querySelectorAll(".edit-form-d input, .edit-form-d textarea, .edit-form-d select");function editProfileHandler(e){inputs.forEach(function(e){"_token"!=e.name&&(e.disabled=!1)}),actions.style.display="block",editProfileButton.style.display="none"}function saveEditHandler(e){let t={};inputs.forEach(e=>{"SELECT"===e.tagName&&e.value!=e.dataset.placeholder?t[e.name]=e.value:e.value==e.placeholder&&"_token"!==e.name||(t[e.name]=e.value)}),1!==Object.keys(t).length&&sendAjaxRequest("PATCH",saveEditButton.dataset.href,encodeForAjax(t),e=>{actions.style.display="none",editProfileButton.style="",inputs.forEach(e=>{"SELECT"===e.tagName&&e.value!=e.dataset.placeholder?e.dataset.placeholder=e.value:e.value==e.placeholder&&"_token"!==e.name||"_token"!=e.name&&(e.placeholder=e.value),e.disabled=!0}),saveEditButton.dataset.onEdit&&window[saveEditButton.dataset.onEdit](e)},e=>{serverSideValidation(inputs[0].form,e)})}function cancelEditHandler(e){inputs.forEach(e=>{"_token"!=e.name&&"SELECT"!=e.tagName?e.value=e.placeholder:"SELECT"===e.tagName&&(e.value=e.dataset.placeholder),e.disabled=!0}),actions.style.display="none",editProfileButton.style=""}editProfileButton&&editProfileButton.addEventListener("click",editProfileHandler),saveEditButton&&saveEditButton.addEventListener("click",saveEditHandler),cancelEditButton&&cancelEditButton.addEventListener("click",cancelEditHandler);const avatar=document.getElementById("userAvatar"),nav_avatar=document.getElementById("navBarAvatar");let saved_url=avatar?avatar.src:null;const edit_avatar=document.getElementById("editAvatar"),edit_avatar_in=document.getElementById("editAvatarInput"),avatar_file=document.getElementById("fileAvatar"),cancel_avatar=document.getElementById("cancelAvatar"),save_avatar=document.getElementById("saveAvatar");edit_avatar&&edit_avatar.addEventListener("click",e=>{edit_avatar.classList.toggle("d-none"),edit_avatar_in.classList.toggle("d-none")}),avatar_file&&avatar_file.addEventListener("change",e=>{let t=new Image;t.onload=(()=>{let e=document.createElement("canvas");e.width=600,e.height=600;let a=e.getContext("2d"),n=Math.min(t.width,t.height),d=600/n;a.scale(d,d),a.drawImage(t,(n-t.width)/2,(n-t.height)/2),avatar.src=e.toDataURL(),nav_avatar.src=e.toDataURL()}),t.src=URL.createObjectURL(avatar_file.files[0])}),cancel_avatar&&cancel_avatar.addEventListener("click",e=>{avatar.src=saved_url,nav_avatar.src=saved_url,edit_avatar.classList.toggle("d-none"),edit_avatar_in.classList.toggle("d-none")}),save_avatar&&save_avatar.addEventListener("click",e=>{let t={avatar:avatar.src,_token:edit_avatar_in.children[0].value};sendAjaxRequest("PATCH",saveEditButton.dataset.href,encodeForAjax(t),()=>{saved_url=avatar.src}),console.log(avatar_file.value),edit_avatar.classList.toggle("d-none"),edit_avatar_in.classList.toggle("d-none")});