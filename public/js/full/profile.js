const editProfileButton = document.getElementById('editProfile')
const saveEditButton = document.getElementById('saveEdit')
const cancelEditButton = document.getElementById('cancelEdit')
const actions = document.getElementById('editActions')
const inputs = document.querySelectorAll('.edit-form-d input, .edit-form-d textarea, .edit-form-d select')

function editProfileHandler(e){
  inputs.forEach(function (field) {
    if (field.name != '_token') {
      field.disabled = false
    }
  })
  actions.style.display = 'block'
  editProfileButton.style.display = 'none'
}

function saveEditHandler(e) {
  let data = {}
  inputs.forEach((field) => {
    if (field.tagName === 'SELECT' && field.value != field.dataset.placeholder) {
      data[field.name] = field.value
    } else if (field.value != field.placeholder || field.name === '_token') {
      data[field.name] = field.value
    }
  })

  if (Object.keys(data).length === 1) return

  sendAjaxRequest('PATCH', saveEditButton.dataset.href, encodeForAjax(data),
    (response)=>{
      actions.style.display = 'none'
      editProfileButton.style = ''
      inputs.forEach((field) => {
        if (field.tagName === 'SELECT' && field.value != field.dataset.placeholder) {
          field.dataset.placeholder = field.value
        } else if (field.value != field.placeholder || field.name === '_token') {
          if (field.name != '_token') {
            field.placeholder = field.value
          }
        }
        field.disabled = true
      })
      if (saveEditButton.dataset.onEdit)
        window[saveEditButton.dataset.onEdit](response)
    },
    (response)=>{serverSideValidation(inputs[0].form, response)}
  )
}

function cancelEditHandler(e) {
  inputs.forEach((field) => {
    if (field.name != '_token' && field.tagName != 'SELECT')
      field.value = field.placeholder
    else if (field.tagName === 'SELECT')
      field.value = field.dataset.placeholder
    field.disabled = true
  })
  actions.style.display = 'none'
  editProfileButton.style = ''
}

if (editProfileButton) {
    editProfileButton.addEventListener('click', editProfileHandler)
}

if (saveEditButton) {
    saveEditButton.addEventListener('click', saveEditHandler)
}

if (cancelEditButton) {
    cancelEditButton.addEventListener('click', cancelEditHandler)
}

const avatar = document.getElementById('userAvatar')
const nav_avatar = document.getElementById('navBarAvatar')
let saved_url = (avatar)? avatar.src : null
const edit_avatar = document.getElementById('editAvatar')
const edit_avatar_in = document.getElementById('editAvatarInput')
const avatar_file = document.getElementById('fileAvatar')
const cancel_avatar = document.getElementById('cancelAvatar')
const save_avatar = document.getElementById('saveAvatar')

if (edit_avatar) {
  edit_avatar.addEventListener('click', (e) => {
    edit_avatar.classList.toggle('d-none')
    edit_avatar_in.classList.toggle('d-none')
  })
}

if (avatar_file) {
  avatar_file.addEventListener('change', (e) => {
    let img = new Image()
    img.onload = () => {
      let crop_canvas = document.createElement('canvas')
      crop_canvas.width = 600
      crop_canvas.height = 600
      let crop = crop_canvas.getContext('2d')
      let limiting = Math.min(img.width,img.height)
      let sf = 600/limiting
      crop.scale(sf, sf)
      crop.drawImage(img, (limiting - img.width)/2, (limiting - img.height)/2)
      avatar.src = crop_canvas.toDataURL()
      nav_avatar.src = crop_canvas.toDataURL()
    }
    img.src = URL.createObjectURL(avatar_file.files[0])
  })
}

if (cancel_avatar) {
  cancel_avatar.addEventListener('click', (e) => {
    avatar.src = saved_url
    nav_avatar.src = saved_url
    edit_avatar.classList.toggle('d-none')
    edit_avatar_in.classList.toggle('d-none')
  })
}

if (save_avatar) {
  save_avatar.addEventListener('click', (e) => {
    let data = {'avatar':avatar.src, '_token':edit_avatar_in.children[0].value}
    sendAjaxRequest('PATCH', saveEditButton.dataset.href, encodeForAjax(data), ()=>{
      saved_url = avatar.src
    })
    console.log(avatar_file.value)
    edit_avatar.classList.toggle('d-none')
    edit_avatar_in.classList.toggle('d-none')
  })
}
