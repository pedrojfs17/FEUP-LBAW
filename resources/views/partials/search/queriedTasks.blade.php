@if (count($tasks) > 0)
  @each('partials.tasks.taskSummary', $tasks, 'task')
@else
  <h6 class="text-muted">No tasks found!</h6>
@endif
