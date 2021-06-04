@push('scripts')
  <script src="{{ asset('js/bs.js') }}" defer></script>
@endpush

<div class="modal fade" data-id="{{ $task->id }}" id="task{{$task->id}}Modal" tabindex="-1"
     aria-labelledby="tasks{{$task->id}}ModalLabel"
     aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        @include('partials.tasks.taskModalBreadcrumb',['task'=>$task])
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <section
        class="status-{{ str_replace(' ', '-', strtolower($task->task_status)) }} text-light px-3 py-2 text-bg-check">
        {{$task->task_status}}
      </section>
      <div class="modal-body d-grid gap px-sm-5">
        <header>
          @include('partials.tasks.taskModalInfo',['task'=>$task])
          @if (!$task->project()->first()->closed && $role != 'Reader')
            @include('partials.tasks.taskModalInfoForm',['task'=>$task])
          @endif
          <hr>
        </header>
        <div>
          <div>
            <h5 class="d-inline-block mr-3">Subtasks</h5>
            @if (!$task->project()->first()->closed && $role != 'Reader')
              <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
                 href=".multi-collapse-{{$task->id}}-sub" role="button"
                 aria-controls="task{{$task->id}}UpdateSubTask task{{$task->id}}SubTask"><i
                  class="bi bi-pencil"></i></a>
              @include('partials.tasks.taskModalSubtasksForm',['task'=>$task])
            @endif
            @include('partials.tasks.taskModalSubtasks',['task'=>$task])
          </div>
          <hr>
          <div>
            <h5 class="d-inline-block mr-3">Waiting On</h5>
            @if (!$task->project()->first()->closed && $role != 'Reader')
              <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
                 href=".multi-collapse-{{$task->id}}-wait" role="button"
                 aria-controls="task{{$task->id}}UpdateWaiting task{{$task->id}}Waiting"><i
                  class="bi bi-pencil"></i></a>
              @include('partials.tasks.taskModalWaitingForm',['task'=>$task])
            @endif
            @include('partials.tasks.taskModalWaiting',['task'=>$task])
            <hr>
          </div>
          <div class="row gx-0">
            @include('partials.tasks.taskModalChecklist',['task'=>$task])
            <div class="col-12 col-lg-6">
              <h5 class="d-inline-block mr-3">Assigned to:</h5>
              @if (!$task->project()->first()->closed && $role != 'Reader')
                <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
                   href=".multi-collapse-{{$task->id}}-assign" role="button"
                   aria-controls="task{{$task->id}}UpdateAssign task{{$task->id}}Assign"><i
                    class="bi bi-pencil"></i></a>
                @include('partials.tasks.taskModalAssignForm',['task'=>$task])
              @endif
              @include('partials.tasks.taskModalAssign',['task'=>$task])
            </div>
            <hr>
          </div>
          <div>
            <h5 class=" d-inline-block mr-3">Tags</h5>
            @if (!$task->project()->first()->closed && $role != 'Reader')
              <a class="text-muted float-end edit-task" data-bs-toggle="collapse" data-editing="false"
                 href=".multi-collapse-{{$task->id}}" role="button"
                 aria-controls="task{{$task->id}}UpdateTag task{{$task->id}}Tags"><i class="bi bi-pencil"></i></a>
              @include('partials.tasks.taskModalTagsForm',['task'=>$task])
            @endif
            @include('partials.tasks.taskModalTags',['task'=>$task])
            <hr>
          </div>
          <div class="mb-3">
            <h5>Comments</h5>
            <div class="mb-3 task-comments">
              @foreach ($task->comments as $comment)
                @if ($comment->parent == null)
                  @include('partials.comment', ['comment' => $comment])
                @endif
              @endforeach
            </div>
            <div>
              <form class="d-flex">
                <button type="submit" disabled style="display: none" aria-hidden="true"></button>
                <div class="col me-2">
                  <input id="commentOn{{$task->id}}" class="form-control me-3" type="text" name='text'
                         placeholder="Add comment" aria-describedby="inputCommentFeedback">
                  <div class="invalid-feedback" id="inputCommentFeedback"></div>
                </div>
                <button type="button"
                        class="btn btn-primary btn-add-comment btn-add-comment flex-grow-0 align-self-start"
                        data-task="{{$task->id}}" data-href="/api/project/{{$task->project}}/task/{{$task->id}}/comment"
                        data-author="{{$user->account->id}}">Comment
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
      @if (!$task->project()->first()->closed && $role != 'Reader')
        <div class="modal-footer">
          <button type="button" class="btn btn-danger btn-danger-red delete-task-button mx-0" data-bs-dismiss="modal"
                  data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}"><i
              class="bi bi-trash"></i> Delete Task
          </button>
        </div>
      @endif
    </div>
  </div>
</div>
