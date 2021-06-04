<div class="carousel-item @if ($active) active @endif">
  <div class="col-12 col-md-4">
    <div class="card mb-2">
      <div class="card-header text-center text-bg-check"
           style="background-color: {{$team_member->color}}">
          {{$team_member->account->username}}
      </div>
      <div class="card-body ">
        <div class="d-grid gap-2 ">
          @foreach($team_member->tasks as $task)
            @if ($task->project == $project->id)
              <button type="button" style="background-color: #e7e7e7" class="btn text-start subtask-{{ str_replace(' ', '-', strtolower($task->task_status)) }} open-task" data-target="task{{ $task->id }}Modal" data-href="/api/project/{{ $task->project }}/task/{{ $task->id }}">{{ $task->name }}</button>
            @endif
          @endforeach
        </div>
      </div>
    </div>
  </div>
</div>
