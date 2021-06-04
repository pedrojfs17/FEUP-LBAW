const membersSearchBar = document.getElementById('searchMembers')
const membersSearchButton = document.getElementById('button-search-members')
const membersDiv = document.getElementById('members')
const membersSpinner = document.getElementById('membersSpinner')
const addedMembers = document.getElementById('added-members')

membersSearchBar.addEventListener('keyup', function () {
  membersDiv.innerHTML = ""
  membersSpinner.classList.remove('d-none')
  sendGetMembersInviteRequest(membersSearchButton.dataset.href + "&query=" + membersSearchBar.value.trim());
})

membersSearchButton.addEventListener('click', function () {
  membersDiv.innerHTML = ""
  membersSpinner.classList.remove('d-none')
  sendGetMembersInviteRequest(membersSearchButton.dataset.href + "&query=" + membersSearchBar.value.trim());
})

function receivedMembersInvite(responseText) {
  membersDiv.innerHTML = JSON.parse(responseText)
  membersSpinner.classList.add('d-none')

  let addButtons = document.querySelectorAll('.add-member-btn')
  addButtons.forEach(function (btn) {
    btn.addEventListener('click', function () {
      let inviteRequest = new XMLHttpRequest()

      inviteRequest.open("POST", "/api/project/" + document.getElementById('addMembers').dataset.project + "/invite", true)
      inviteRequest.setRequestHeader("Accept", "application/json")
      inviteRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      inviteRequest.send(encodeForAjax({
        '_token' :  document.querySelector('input[name="_token"]').value,
        'client' : btn.dataset.id
      }))

      let memberCard = btn.parentElement.parentElement
      addedMembers.appendChild(memberCard)
      memberCard.querySelector('button').remove()
    })
  })

  let paginationLinks = document.getElementsByClassName('paginator-link')
  Array.from(paginationLinks).forEach(link => link.addEventListener('click', function() {
    membersDiv.innerHTML = ""
    membersSpinner.classList.remove('d-none')
    sendGetMembersInviteRequest(link.dataset.href + '&project=' + document.getElementById('addMembers').dataset.project);
  }))
}

function sendGetMembersInviteRequest(url) {
  let membersRequest = new XMLHttpRequest()

  membersRequest.onreadystatechange = function() {
    if (membersRequest.readyState === XMLHttpRequest.DONE) {
      if (membersRequest.status === 200) {
        receivedMembersInvite(this.responseText)
      }
      else {
        alert('There was an error ' + membersRequest.status);
      }
    }
  }

  membersRequest.open("GET", url, true)
  membersRequest.setRequestHeader("Accept", "application/json")
  membersRequest.send()
}

