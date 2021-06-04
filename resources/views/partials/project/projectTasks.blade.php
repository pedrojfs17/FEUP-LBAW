@foreach ($tasks as $task)
  @include('partials.tasks.task', ['task' => $task])
@endforeach
<div class="modal-container"></div>
