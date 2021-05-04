<div class="col mb-3 task-group status-{{str_replace(" ", "-", strtolower($status))}}" data-status="{{$status}}" data-href="/api/project/{{$project->id}}/task/">
  <div class="card">
    <div class="card-header text-center text-white ">
      {{$status}}
    </div>
    <div class="card-body ">
      <div class="d-grid gap-2 ">
        @foreach ($tasks as $task)
          @if ($task->task_status == $status)
            <div id="task{{$task->id}}" data-id="{{$task->id}}" class="btn text-start draggable" type="button" draggable="true">{{$task->name}}</div>
          @endif
        @endforeach
      </div>
    </div>
  </div>
</div>
