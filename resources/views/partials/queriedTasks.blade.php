@if (count($tasks) > 0)
  @each('partials.taskSummary', $tasks, 'task')
@else
  <h6 class="text-muted">No tasks found!</h6>
@endif
