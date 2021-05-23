@foreach ($taskArray as $task)
  <button type="button" style="background-color: #e7e7e7; width:100%"
          class="btn my-1 text-start subtask-{{ str_replace(' ', '-', strtolower($task->task_status)) }}"
          data-bs-toggle="modal" data-bs-dismiss="modal"
          data-bs-target="#task{{ $task->id }}Modal">{{ $task->name }}</button>
@endforeach

