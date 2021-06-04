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
  parent.innerHTML += text
}

function addComment(text) {
  let parent = document.querySelectorAll('.task-comments')[0]
  parent.innerHTML += text;
  commentEventListener(parent)
}

function getDate() {
  let d = new Date().toISOString().split('T')
  return d[0] + " " + d[1].substr(0, 8)
}

function sendReplyRequest(button) {
  button.disabled = true
  let replyInput = document.getElementById('replyTo' + button.dataset.comment)
  let replyText = replyInput.value.trim()

  sendAjaxRequest('POST', button.dataset.href, encodeForAjax({
      '_token' :  document.querySelector('input[name="_token"]').value,
      'text' : replyText,
      'parent' : button.dataset.comment,
      'date' : getDate(),
      'author' : button.dataset.author
    }), (response) => {
      addReply(button.dataset.comment, response)
      replyInput.value = ''
      let event = new Event('change');
      replyInput.dispatchEvent(event);
      button.disabled = false
    },
    (response) => {
      serverSideValidation(button.form, response)
      button.disabled = false
    }
  )
}

function sendCommentRequest(button) {
  button.disabled = true
  let commentInput = document.getElementById('commentOn' + button.dataset.task)
  let commentText = commentInput.value.trim()

  sendAjaxRequest('POST', button.dataset.href, encodeForAjax({
      '_token' :  document.querySelector('input[name="_token"]').value,
      'text' : commentText,
      'date' : getDate(),
      'author' : button.dataset.author
    }), (response) => {
      addComment(response)
      commentInput.value = ''
      let event = new Event('change');
      commentInput.dispatchEvent(event);
      button.disabled = false
    },
    (response) => {
      serverSideValidation(button.form, response)
      button.disabled = false
    }
  )
}


