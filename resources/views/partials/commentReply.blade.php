<div class="comment-replies my-2 ms-5">
  <div class="comment-body d-flex ms-2">
    <a class='text-decoration-none' target="_blank" rel="noopener noreferrer" href="/profile/{{$reply->author()->first()->account->username}}">
      <img class="rounded-circle mt-1" src="{{ url($reply->author()->first()->avatar) }}"
          width="30px" height="30px"
          alt="avatar">
    </a>
    <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2"
         style="background-color: #e7e7e7">
      {{$reply->comment_text}}
      <small class="text-muted float-end">{{ $reply->getReadableCommentDate() }} ago</small>
    </div>
  </div>
</div>
