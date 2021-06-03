<div class="card m-2" data-id="{{ $task->id }}" id="task-{{ $task->id }}">
  <div class="card-header status-{{ str_replace(' ', '-', strtolower($task->task_status)) }}"></div>

  <div class="card-body d-flex flex-column">
    <h5 class="card-title">{{ $task->name }}</h5>

    <div class="d-flex flex-sm-column flex-row mb-2">
      @if (count($task->checklistItems) > 0)
        <div class="checklist my-auto">
          <span
            class="{{ count($task->checklistItems->where('completed', true)) === count($task->checklistItems) ? 'text-success' : 'text-secondary'  }} px-0 py-0">
              <i class="bi bi-check2-circle"></i>
              <span class="d-none d-sm-inline-block">
                {{ count($task->checklistItems->where('completed', true)) }}/{{ count($task->checklistItems) }}
              </span>
          </span>
        </div>
      @endif

      @if (count($task->subtasks) > 0)
        <div class="subtasks my-auto mx-1 mx-sm-0">
        <span
          class="{{ count($task->subtasks->where('task_status', 'Completed')) === count($task->subtasks) ? 'text-success' : 'text-secondary'  }} px-0 py-0">
            <i class="bi bi-list-check"></i>
            <span class="d-none d-sm-inline-block">
              {{ count($task->subtasks->where('task_status', 'Completed')) }}/{{ count($task->subtasks) }}
            </span>
        </span>
        </div>
      @endif

      @if (count($task->waitingOn) > 0)
        <div class="waiting-on my-auto mx-1 mx-sm-0">
        <span
          class="{{ count($task->waitingOn->where('task_status', 'Completed')) === count($task->waitingOn) ? 'text-success' : 'text-secondary'  }} px-0 py-0">
            <i class="bi bi-clock"></i>
            <span class="d-none d-sm-inline-block">
              {{ count($task->waitingOn->where('task_status', 'Completed')) }}/{{ count($task->waitingOn) }}
            </span>
        </span>
        </div>
      @endif

      @if (isset($task->due_date) > 0)
        <div class="due-date my-auto mx-1 mx-sm-0">
        <span class="text-muted">
            <i class="bi bi-calendar-date"></i> <span class="d-none d-sm-inline-block">{{ $task->getReadableDueDate() }}</span>
        </span>
        </div>
      @endif
    </div>

    <div class="d-flex flex-wrap gap-2 my-2 mt-auto task{{$task->id}}Tags">
      @each('partials.tasks.tag', $task->tags, 'tag')
    </div>

    <div class="d-none d-sm-flex justify-content-between mt-2">
      <ul class="position-relative avatar-overlap d-none d-md-block" style="width: max-content; z-index: 1">
        @foreach ($task->assignees as $member)
          <li class="avatar-overlap-item" style="z-index: {{ 3 - $loop->iteration }}">
            <img class="rounded-circle"
                 src="{{ url($member->avatar) }}"
                 width="40px" height="40px"
                 alt="avatar">
          </li>
          @if ($loop->iteration == 3)
            @break
          @endif
        @endforeach
        @if (count($task->assignees) > 3)
          <li class="avatar-overlap-item" style="z-index: -1">
            <div class="number-circle">+{{ count($task->assignees) - 3 }}</div>
          </li>
        @endif
      </ul>
      @if(count($task->comments) > 0)
        <span class="text-end align-self-center">{{ count($task->comments) }}<i
            class="fas fa-comment-alt m-2"></i></span>
      @endif
    </div>

    <a data-href="/api/project/{{ $task->project }}/task/{{ $task->id }}" data-target="task{{ $task->id }}Modal" role="button" class="stretched-link p-0 open-task"></a>
  </div>
</div>
