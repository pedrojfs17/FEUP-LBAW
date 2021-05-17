@foreach ($tasks as $task)
  @include('partials.task', ['task' => $task])
@endforeach
<div class="modal-container"></div>
