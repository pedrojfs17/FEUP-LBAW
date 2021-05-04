<div class="col mb-3 task-group status-{{str_replace(" ", "-", strtolower($status))}}" data-status="{{$status}}" data-href="/api/project/{{$project->id}}/task/">
  <div class="card">
    <div class="card-header text-center text-white ">
      {{$status}}
    </div>
    <div class="card-body ">
      <div class="d-grid gap-2 ">
        @foreach ($tasks as $task)
          @if ($task->task_status == $status)
            <button id="task{{$task->id}}" type="button" draggable="true" data-id="{{$task->id}}" class="btn text-start draggable" data-bs-toggle="modal" data-bs-dismiss="modal" data-bs-target="#task{{ $task->id }}Modal">{{ $task->name }}</button>
          @endif
        @endforeach
      </div>
    </div>
  </div>
</div>
