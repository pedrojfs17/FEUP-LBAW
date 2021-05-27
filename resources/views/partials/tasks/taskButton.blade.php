@foreach ($taskArray as $task)
  <button type="button" style="background-color: #e7e7e7; width:100%"
          class="btn my-1 text-start open-task subtask-{{ str_replace(' ', '-', strtolower($task->task_status)) }}"
          data-bs-dismiss="modal"
          data-href="/api/project/{{ $task->project }}/task/{{ $task->id }}"
          data-target="#task{{ $task->id }}Modal">{{ $task->name }}</button>
@endforeach

