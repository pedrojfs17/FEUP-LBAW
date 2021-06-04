<div class="comment mb-3">
  <div class="comment-body d-flex ms-2">
    <a class='text-decoration-none' target="_blank" rel="noopener noreferrer" href="/profile/{{$comment->author()->first()->account->username}}">
      <img class="rounded-circle mt-1" src="{{ url($comment->author()->first()->avatar) }}" width="30"
          height="30"
          alt="avatar">
    </a>
    <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2"
         style="background-color: #e7e7e7">
      {{$comment->comment_text}} <small class="text-muted float-end">{{ $comment->getReadableCommentDate() }} ago</small>
    </div>
    <a class="p-1 mx-2 d-flex align-items-center text-decoration-none" data-bs-toggle="collapse"
       href="#comment{{$comment->id}}reply"
       role="button" aria-expanded="false" aria-controls="comment{{$comment->id}}reply">
      <i class="bi bi-chat-text fs-5 text-muted"></i>
      @if (count($comment->replies) > 0)
      <span class="badge rounded-pill badge-notify d-none d-sm-inline-block">{{count($comment->replies)}}</span>
      @endif
    </a>
  </div>
  <div id="comment{{$comment->id}}reply" class="collapse">
    <div id="comment{{$comment->id}}replyDiv">
    @foreach ($comment->replies as $reply)
      @include('partials.tasks.commentReply', ['reply' => $reply])
    @endforeach
    </div>
    <div class="comment-footer mt-2 ms-5">
      <form class='d-flex'>
        <div class="col me-2">
          <input id="replyTo{{$comment->id}}" class="form-control me-3" type="text" name='text' placeholder="Add comment" aria-describedby="inputReplyFeedback">
          <div class="invalid-feedback flex-grow-0" id="inputReplyFeedback"></div>
        </div>
        <button type="button" class="btn btn-outline-secondary btn-add-reply flex-grow-0 align-self-start" data-comment="{{$comment->id}}"
              data-href="/api/project/{{$task->project}}/task/{{$task->id}}/comment"
              data-author="{{$user->account->id}}">Reply
        </button>
      </form>
    </div>
  </div>
</div>
