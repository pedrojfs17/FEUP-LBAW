let inviteButton = document.querySelectorAll('.acc-invite-btn')
inviteButton.forEach(invButton => {
  invButton.addEventListener('click', ()=>{
    let obj= {}
    obj['decision'] = invButton.dataset.decision
    obj['_token'] = invButton.form.querySelector('input[name="_token"]').value
    sendAjaxRequest('PATCH', invButton.form.dataset.href, encodeForAjax(obj), 
      (response) => {
        let inviteActions = document.getElementById(invButton.form.dataset.invite + 'Actions')
        if (invButton.dataset.decision === '0')
          inviteActions.textContent = 'Rejected'
        else {
          inviteActions.innerHTML = '<a href=' + invButton.form.dataset.project + '>Go to project</a>'
        }
      })
  })
})

let removeInviteButton = document.querySelectorAll('.remove-invite-btn')
removeInviteButton.forEach(invButton => {
  invButton.addEventListener('click', (ev) => {
    let obj= {}
    obj['decision'] = invButton.dataset.decision
    obj['_token'] = document.querySelector('input[name="_token"]').value
    sendAjaxRequest('PATCH', invButton.dataset.href, encodeForAjax(obj), 
      (response) => {
        invButton.outerHTML = 'Invite Removed'
      })
  })
})