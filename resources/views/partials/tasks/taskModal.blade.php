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
          <div id='taskInfo'>
            <h3 class="d-inline-block">{{$task->name}}</h3>
            <button class="btn btn-outline-secondary float-end editButton" type="button" form='editTaskForm'><i class="bi bi-pencil"></i></button>
            @if ($task->due_date)
            <p class="text-muted">Due by: {{$task->getReadableDueDate()}}</p>
            @endif
            <h6 class="text-muted">{{$task->description}}</h6>
          </div>
          <form id='editTaskForm' action='../../api/project/{{$task->project}}/task/{{$task->id}}' class='d-none' data-info='taskInfo'>
            @csrf
            <label for="name" class="form-label mb-1">Name</label>
            <span class='d-flex'>
              <input type='text' placeholder='{{$task->name}}' value='{{$task->name}}' class='form-control' name='name'>
              <button class="btn btn-outline-secondary float-end mx-1 cancelButton" type="button"><i class="bi bi-x fa-lg"></i></button>
              <button class="btn btn-outline-secondary float-end saveButton" type="button"><i class="bi bi-check fa-lg"></i></button>
            </span>
            <label for="due_date" class="form-label my-1">Due date</label>
            @if ($task->due_date)
            <input type="date" value="{{(new DateTime($task->due_date))->format('Y-m-d')}}" placeholder="{{(new DateTime($task->due_date))->format('Y-m-d')}}" class="form-control" name="due_date">
            @else
            <input type="date" value="" placeholder="" class="form-control" name="due_date">
            @endif
            <label for="description" class="form-label my-1">Description</label>
            <textarea type='text' placeholder='{{$task->description}}' class='form-control' name='description'>{{$task->description}}</textarea>
          </form>
          <hr>
        </header>
        <div>
          <div>
            <h5 class=" d-inline-block mr-3">Subtasks</h5>
            <a class="text-muted float-end edit-tags" data-bs-toggle="collapse" data-editing="false"
               href=".multi-collapse-{{$task->id}}-sub" role="button"
               aria-controls="task{{$task->id}}UpdateSubTask task{{$task->id}}SubTask"><i class="bi bi-pencil"></i></a>
            <div id="task{{$task->id}}UpdateSubTask" class="collapse mb-3 multi-collapse-{{$task->id}}-sub"
                 aria-expanded="false">
              <form data-id="task{{$task->id}}SubTask"
                    data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/subtask">
                @csrf
                <select class="form-control subtask-selection" multiple="multiple" name="subtask"
                        id="subtask-selection-{{$task->id}}">
                  @foreach ($task->project()->first()->tasks as $subtask)
                    @if ($task->id == $subtask->id)
                      @continue
                    @elseif($task->subtasks()->where('id',$subtask->id)->count()!==0)
                      <option value="{{$subtask->id}}" selected="selected">{{$subtask->name}}</option>
                    @else
                      <option value="{{$subtask->id}}">{{$subtask->name}}</option>
                    @endif
                  @endforeach
                </select>
                <button type="submit" class="d-none"></button>
              </form>
            </div>
            <div class=" my-3 multi-collapse-{{$task->id}}-sub show" id="task{{$task->id}}SubTask" aria-expanded="true">
              @include('partials.tasks.taskButton',['taskArray'=>$task->subtasks])
            </div>
          </div>
          <div>
            <h5 class="d-inline-block mr-3">Waiting On</h5>
            <a class="text-muted float-end edit-tags" data-bs-toggle="collapse" data-editing="false"
               href=".multi-collapse-{{$task->id}}-wait" role="button"
               aria-controls="task{{$task->id}}UpdateWaiting task{{$task->id}}Waiting"><i class="bi bi-pencil"></i></a>
            <div id="task{{$task->id}}UpdateWaiting" class="collapse mb-3 multi-collapse-{{$task->id}}-wait"
                 aria-expanded="false">
              <form data-id="task{{$task->id}}Waiting"
                    data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/waiting_on">
                @csrf
                <select class="form-control waiting-selection" multiple="multiple" name="waiting"
                        id="waiting-selection-{{$task->id}}">
                  @foreach ($task->project()->first()->tasks as $task_wait)
                    @if ($task->id == $task_wait->id)
                      @continue
                    @elseif($task->waitingOn()->where('id',$task_wait->id)->count()!==0)
                      <option value="{{$task_wait->id}}" selected="selected">{{$task_wait->name}}</option>
                    @else
                      <option value="{{$task_wait->id}}">{{$task_wait->name}}</option>
                    @endif
                  @endforeach
                </select>
                <button type="submit" class="d-none"></button>
              </form>
            </div>
            <div class="my-3 multi-collapse-{{$task->id}}-wait show" id="task{{$task->id}}Waiting" aria-expanded="true">
              @include('partials.tasks.taskButton',['taskArray'=>$task->waitingOn])
            </div>
            <hr>
          </div>
          <div class="row gx-0">
            <div class="col-12 col-lg-6 pe-3" id="task{{$task->id}}CheckList">
              @include('partials.checklistItems',['task'=>$task])
            </div>
            <div class="col-12 col-lg-6">
              <h5 class="d-inline-block mr-3">Assigned to:</h5>
              <a class="text-muted float-end edit-tags" data-bs-toggle="collapse" data-editing="false"
                 href=".multi-collapse-{{$task->id}}-assign" role="button"
                 aria-controls="task{{$task->id}}UpdateAssign task{{$task->id}}Assign"><i class="bi bi-pencil"></i></a>
              <div id="task{{$task->id}}UpdateAssign" class="collapse mb-3 multi-collapse-{{$task->id}}-assign"
                   aria-expanded="false">
                <form data-id="task{{$task->id}}Assign"
                      data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/assignment">
                  @csrf
                  <select class="form-control assign-selection" multiple="multiple" name="assign"
                          id="assign-selection-{{$task->id}}">
                    @foreach ($task->project()->first()->teamMembers as $team_member)
                      @if($task->assignees()->where('id',$team_member->id)->count()!==0)
                        <option value="{{$team_member->id}}"
                                selected="selected">{{$team_member->account->username}}</option>
                      @else
                        <option value="{{$team_member->id}}">{{$team_member->account->username}}</option>
                      @endif
                    @endforeach
                  </select>
                  <button type="submit" class="d-none"></button>
                </form>
              </div>
              <div class="my-3 multi-collapse-{{$task->id}}-assign show" id="task{{$task->id}}Assign"
                   aria-expanded="true">
                @include('partials.clientPhoto',['assignees'=>$task->assignees])
              </div>
            </div>
            <hr>
          </div>
          <div>
            <h5 class=" d-inline-block mr-3">Tags</h5>
            <a class="text-muted float-end edit-tags" data-bs-toggle="collapse" data-editing="false"
               href=".multi-collapse-{{$task->id}}" role="button"
               aria-controls="task{{$task->id}}UpdateTag task{{$task->id}}Tags"><i class="bi bi-pencil"></i></a>
            <div id="task{{$task->id}}UpdateTag" class="collapse mb-3 multi-collapse-{{$task->id}}"
                 aria-expanded="false">
              <form data-id="task{{$task->id}}Tags"
                    data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/tag">
                @csrf
                <select class="form-control tag-selection" multiple="multiple" name="tag"
                        id="tag-selection-{{$task->id}}">
                  @foreach ($task->project()->first()->tags as $tag)
                    @if($task->tags()->where('id',$tag->id)->count()!==0)
                      <option value="{{$tag->id}}" selected="selected">{{$tag->name}}</option>
                    @else
                      <option value="{{$tag->id}}">{{$tag->name}}</option>
                    @endif
                  @endforeach
                </select>
                <button type="submit" class="d-none"></button>
              </form>
            </div>
          <div class="flex-wrap gap-2 my-2 mt-auto multi-collapse-{{$task->id}} show" id="task{{$task->id}}Tags" aria-expanded="true">
            @each('partials.tasks.tag', $task->tags, 'tag')
          </div>
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
