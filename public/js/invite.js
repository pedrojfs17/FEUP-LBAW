let inviteButton = document.querySelectorAll('.acc-invite-btn')
inviteButton.forEach(invButton => {
  invButton.addEventListener('click', ()=>{
    let obj= {}
    console.log(invButton.dataset)
    obj['decision'] = invButton.dataset.decision
    obj['_token'] = invButton.parentElement.querySelector('input[name="_token"]').value
     sendPatchAjaxRequest(invButton.parentElement.dataset.href,obj)
  })
})
