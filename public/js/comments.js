function commentEventListener(modal) {
  let replyButtons = modal.getElementsByClassName('btn-add-reply')
  Array.from(replyButtons).forEach(button =>
    button.addEventListener('click', function () {
      sendReplyRequest(button)
    }))

  let commentButtons = modal.getElementsByClassName('btn-add-comment')
  Array.from(commentButtons).forEach(button =>
    button.addEventListener('click', function () {
      sendCommentRequest(button)
    }))
}

function addReply(comment, text) {
  let parent = document.getElementById('comment' + comment + 'replyDiv')
  parent.innerHTML += JSON.parse(text);
}

function addComment(text) {
  let parent = document.querySelectorAll('.task-comments')[0]
  parent.innerHTML += JSON.parse(text);
}

function getDate() {
  let d = new Date().toISOString().split('T')
  return d[0] + " " + d[1].substr(0, 8)
}

function sendReplyRequest(button) {
  let replyText = document.getElementById('replyTo' + button.dataset.comment).value.trim()

  let request = new XMLHttpRequest()
  request.onreadystatechange = function() {
    if (request.readyState === XMLHttpRequest.DONE) {
      if (request.status === 200)
        addReply(button.dataset.comment, this.responseText)
      else {
        alert('There was an error ' + request.status)
      }
    }
  }

  request.open("POST", button.dataset.href, true)
  request.setRequestHeader("Accept", "application/json")
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
  request.send(encodeForAjax({
    '_token' :  document.querySelector('input[name="_token"]').value,
    'text' : replyText,
    'parent' : button.dataset.comment,
    'date' : getDate(),
    'author' : button.dataset.author
  }))
}

function sendCommentRequest(button) {
  let replyText = document.getElementById('commentOn' + button.dataset.task).value.trim()

  let request = new XMLHttpRequest()
  request.onreadystatechange = function() {
    if (request.readyState === XMLHttpRequest.DONE) {
      if (request.status === 200)
        addComment(this.responseText)
      else {
        alert('There was an error ' + request.status)
      }
    }
  }

  request.open("POST", button.dataset.href, true)
  request.setRequestHeader("Accept", "application/json")
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
  request.send(encodeForAjax({
    '_token' :  document.querySelector('input[name="_token"]').value,
    'text' : replyText,
    'date' : getDate(),
    'author' : button.dataset.author
  }))
}


