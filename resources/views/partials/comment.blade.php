<div class="comment mb-3">
  <div class="comment-body d-flex ms-2">
    <img class="rounded-circle mt-1" src="{{ url($comment->author()->first()->avatar) }}" width="30px"
         height="30px"
         alt="avatar">
    <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2"
         style="background-color: #e7e7e7">
      {{$comment->comment_text}} <small class="text-muted float-end">{{ $comment->getReadableCommentDate() }} ago</small>
    </div>
    <a class="p-1 mx-2 d-flex align-items-center" data-bs-toggle="collapse"
       href="#comment{{$comment->id}}reply"
       role="button" aria-expanded="false" aria-controls="comment{{$comment->id}}reply">
      <i class="bi bi-chat-text fs-5 text-muted"></i>
    </a>
  </div>
  <div id="comment{{$comment->id}}reply" class="collapse">
    <div id="comment{{$comment->id}}replyDiv">
    @foreach ($comment->replies as $reply)
      @include('partials.commentReply', ['reply' => $reply])
    @endforeach
    </div>
    <div class="comment-footer d-flex mt-2 ms-5">
      <input id="replyTo{{$comment->id}}" class="form-control me-3" type="text" placeholder="Add comment">
      <button type="button" class="btn btn-outline-secondary btn-sm btn-add-reply" data-comment="{{$comment->id}}"
              data-href="/api/project/{{$task->project}}/task/{{$task->id}}/comment"
              data-author="{{$user->account->id}}">Reply
      </button>
    </div>
  </div>
</div>
