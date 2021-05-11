@push('scripts')
  <script src="{{ asset('js/tooltip.js') }}" defer></script>
@endpush

<div class="modal fade" id="task{{$task->id}}Modal" tabindex="-1" aria-labelledby="tasks{{$task->id}}ModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="tasks{{$task->id}}ModalLabel">
          <ol class="my-0 breadcrumb text-muted">
            <li class="breadcrumb-item">
              <a style="cursor: pointer; font-weight: bolder" data-bs-dismiss="modal">Project</a>
            </li>
            @if (count($task->parent()->get()) > 0)
              <li class="breadcrumb-item" aria-current="page">
                <a style="cursor: pointer; font-weight: bolder" data-bs-target="#task{{$task->parent->parent}}Modal"
                   data-bs-toggle="modal" data-bs-dismiss="modal">{{$task->parent->parent()->first()->name}}</a>
              </li>
            @endif
            <li class="breadcrumb-item active" aria-current="page">{{$task->name}}</li>
          </ol>
        </nav>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <section
        class="status-{{ str_replace(' ', '-', strtolower($task->task_status)) }} text-light px-3 py-2 text-bg-check">
        {{$task->task_status}}
      </section>
      <div class="modal-body d-grid gap px-sm-5">
        <header>
          <h3 class="d-inline-block">{{$task->name}}</h3>
          <button class="btn btn-outline-secondary float-end" type="button"><i class="bi bi-pencil"></i></button>
          <p class="text-muted">{{$task->due_date}}</p>
          <h6 class="text-muted">{{$task->description}}</h6>
          <hr>
        </header>
        <div>
          <h5>Subtasks</h5>
          <div class="d-grid gap-2 my-3">
            @foreach ($task->subtasks as $subtask)
              <button type="button" style="background-color: #e7e7e7"
                      class="btn text-start subtask-{{ str_replace(' ', '-', strtolower($subtask->task()->first()->task_status)) }}"
                      data-bs-toggle="modal" data-bs-dismiss="modal"
                      data-bs-target="#task{{ $subtask->task()->first()->id }}Modal">{{ $subtask->task()->first()->name }}</button>
            @endforeach
          </div>
          <h5>Waiting On</h5>
          <div class="d-grid gap-2 my-3">
            @foreach ($task->waitingOn as $waitingOn)
              <button type="button" style="background-color: #e7e7e7"
                      class="btn text-start subtask-{{ str_replace(' ', '-', strtolower($waitingOn->task_status)) }}"
                      data-bs-toggle="modal" data-bs-dismiss="modal"
                      data-bs-target="#task{{ $waitingOn->id }}Modal">{{ $waitingOn->name }}</button>
            @endforeach
          </div>
          <hr>
        </div>
        <div class="row gx-0">
          <div class="col-12 col-lg-6 pe-2">
            <h5 class=" d-inline-block mr-3">Checklist</h5>
            <p
              class=" d-inline-block text-secondary">@if (count($task->checkListItems) > 0) {{ count($task->checklistItems->where('completed', true)) / count($task->checklistItems) * 100 }}
              % @else 0% @endif</p>
            <div class="progress" style="height:5px;">
              <div class="progress-bar" role="progressbar"
                   style="width: @if (count($task->checkListItems) > 0) {{ count($task->checklistItems->where('completed', true)) / count($task->checklistItems) * 100 }}%; @else 0; @endif height:5px; background-color:green;"
                   aria-valuenow=@if (count($task->checkListItems) > 0) "{{ count($task->checklistItems->where('completed', true)) / count($task->checklistItems) * 100 }}" @else
                "0" @endif aria-valuemin="0" aria-valuemax="100">
            </div>
          </div>
          <div class="d-grid gap-2 my-3">
            @foreach ($task->checklistItems as $item)
              <div class="form-check">
                <label class="form-check-label">
                  {{$item->item_text}}
                  <input class="form-check-input" type="checkbox" @if ($item->completed) checked @endif>
                </label>
              </div>
            @endforeach
          </div>
        </div>
        <div class="col-12 col-lg-6 ps-2">
          <h5 class="mb-1">Assigned to:</h5>
          @foreach ($task->assignees as $assignee)
            <img class="rounded-circle" src="{{ url($assignee->avatar) }}" data-bs-toggle="tooltip" data-bs-placement="top" title="{{$assignee->account->username}}" width="40px " height="40px " alt="avatar ">
          @endforeach
        </div>
        <hr>
      </div>
      <div>
        <h5 class=" d-inline-block mr-3">Tags</h5>
        <a class="text-muted float-end" data-bs-toggle="collapse" href="#task{{$task->id}}CreateTag" role="button"
           aria-expanded="false" aria-controls="task{{$task->id}}CreateTag"><i class="bi bi-plus-circle"></i></a>
        <div id="task{{$task->id}}CreateTag" class="collapse mb-3">
          <form class="d-flex">
            <input type="text" class="form-control" placeholder="Tag Name" aria-label="Tag name">
            <input type="color" class="form-control form-control-color mx-2" value="#20c94d" title="Choose tag color">
            <button type="submit" class="btn btn-outline-secondary flex-grow-1">Add</button>
          </form>
        </div>

        <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
          @foreach ($task->tags as $tag)
            <p class="d-inline-block m-0 py-1 px-2 rounded text-bg-check" type="button"
               style="background-color: {{ $tag->color }}">
              <small>{{ $tag->name }}</small>
            </p>
          @endforeach
        </div>
        <hr>
      </div>
      <div>
        <h5>Comments</h5>
        <div class="mb-3">
          @foreach ($task->getParentComments() as $comment)
          <div class="comment mb-3">
            <div class="comment-body d-flex ms-2">
              <img class="rounded-circle mt-1" src="{{ url($comment->author()->first()->avatar) }}" width="30px" height="30px"
                   alt="avatar">
              <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2"
                   style="background-color: #e7e7e7">
                  {{$comment->comment_text}}
              </div>
              <a class="p-1 mx-2 d-flex align-items-center" data-bs-toggle="collapse" href="#comment{{$comment->id}}reply"
                 role="button" aria-expanded="false" aria-controls="comment{{$comment->id}}reply">
                <i class="bi bi-chat-text fs-5 text-muted"></i>
              </a>
            </div>
            <div id="comment{{$comment->id}}reply" class="collapse">
              @foreach ($comment->replies as $reply)
              <div class="comment-replies my-2 ms-5">
                <div class="comment-body d-flex ms-2">
                  <img class="rounded-circle mt-1" src="{{ url($reply->reply->author()->first()->avatar) }}" width="30px" height="30px"
                       alt="avatar">
                  <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2"
                       style="background-color: #e7e7e7">
                      {{$reply->reply->comment_text}}
                  </div>
                </div>
              </div>
              @endforeach
              <div class="comment-footer d-flex mt-2 ms-5">
                <input class="form-control me-3" type="text" placeholder="Add comment">
                <button type="button" class="btn btn-outline-secondary btn-sm">Reply</button>
              </div>
            </div>
          </div>
          @endforeach
        </div>
        <div class="d-flex">
          <input class="form-control me-3" type="text" placeholder="Add comment">
          <button type="button" class="btn btn-primary">Comment</button>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-danger">Delete</button>
      <button type="button" class="btn btn-success" data-bs-dismiss="modal">Save changes</button>
    </div>
  </div>
</div>
</div>
