@push('scripts')
  <script src="{{ asset('js/tooltip.js') }}" defer></script>
@endpush

<div class="modal fade" data-id="{{ $task->id }}" id="task{{$task->id}}Modal" tabindex="-1"
     aria-labelledby="tasks{{$task->id}}ModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="tasks{{$task->id}}ModalLabel">
          <ol class="my-0 breadcrumb text-muted">
            <li class="breadcrumb-item">
              <a style="cursor: pointer; font-weight: bolder" data-bs-dismiss="modal">Project</a>
            </li>
            @if ($task->hasParent())
              <li class="breadcrumb-item" aria-current="page">
                <a class="open-task remove-anchor-css" style="cursor: pointer; font-weight: bolder" data-target="#task{{$task->parent}}Modal"
                   data-href="/api/project/{{ $task->project }}/task/{{ $task->parent }}" data-bs-dismiss="modal">{{$task->parent()->first()->name}}</a>
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
          @include('partials.tasks.taskModalInfo',['task'=>$task])
          @include('partials.tasks.taskModalInfoForm',['task'=>$task])
          <hr>
        </header>
        <div>
          <div>
            <h5 class=" d-inline-block mr-3">Subtasks</h5>
            <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
               href=".multi-collapse-{{$task->id}}-sub" role="button"
               aria-controls="task{{$task->id}}UpdateSubTask task{{$task->id}}SubTask"><i class="bi bi-pencil"></i></a>
            @include('partials.tasks.taskModalSubtasksForm',['task'=>$task])
            @include('partials.tasks.taskModalSubtasks',['task'=>$task])
          </div>
          <div>
            <h5 class="d-inline-block mr-3">Waiting On</h5>
            <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
               href=".multi-collapse-{{$task->id}}-wait" role="button"
               aria-controls="task{{$task->id}}UpdateWaiting task{{$task->id}}Waiting"><i class="bi bi-pencil"></i></a>
            @include('partials.tasks.taskModalWaitingForm',['task'=>$task])
            @include('partials.tasks.taskModalWaiting',['task'=>$task])
            <hr>
          </div>
          <div class="row gx-0">
            @include('partials.tasks.taskModalChecklist',['task'=>$task])
            <div class="col-12 col-lg-6">
              <h5 class="d-inline-block mr-3">Assigned to:</h5>
              <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
                 href=".multi-collapse-{{$task->id}}-assign" role="button"
                 aria-controls="task{{$task->id}}UpdateAssign task{{$task->id}}Assign"><i class="bi bi-pencil"></i></a>
              @include('partials.tasks.taskModalAssignForm',['task'=>$task])
              @include('partials.tasks.taskModalAssign',['task'=>$task])
            </div>
            <hr>
          </div>
          <div>
            <h5 class=" d-inline-block mr-3">Tags</h5>
            <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
               href=".multi-collapse-{{$task->id}}" role="button"
               aria-controls="task{{$task->id}}UpdateTag task{{$task->id}}Tags"><i class="bi bi-pencil"></i></a>
            @include('partials.tasks.taskModalTagsForm',['task'=>$task])
            @include('partials.tasks.taskModalTags',['task'=>$task])
          <hr>
        </div>
        <div>
          <h5>Comments</h5>
          <div class="mb-3 task-comments">
            @foreach ($task->comments as $comment)
              @if ($comment->parent == null)
                @include('partials.comment', ['comment' => $comment])
              @endif
            @endforeach
          </div>
          <div class="d-flex">
            <input id="commentOn{{$task->id}}" class="form-control me-3" type="text" placeholder="Add comment">
            <button type="button" class="btn btn-primary btn-add-comment btn-add-comment" data-task="{{$task->id}}" data-href="/api/project/{{$task->project}}/task/{{$task->id}}/comment"
                    data-author="{{$user->account->id}}">Comment</button>
          </div>
        </div>
      </div>
      <div class="modal-footer px-0">
        <button type="button" class="btn btn-danger delete-task-button mx-0" data-bs-dismiss="modal" data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}"><i class="bi bi-trash"></i> Delete Task</button>
      </div>
    </div>
  </div>
</div>
