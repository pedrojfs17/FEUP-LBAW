<div class="comment-replies my-2 ms-5">
  <div class="comment-body d-flex ms-2">
    <img class="rounded-circle mt-1" src="{{ url($reply->author()->first()->avatar) }}"
         width="30px" height="30px"
         alt="avatar">
    <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2"
         style="background-color: #e7e7e7">
      {{$reply->comment_text}}
    </div>
  </div>
</div>
