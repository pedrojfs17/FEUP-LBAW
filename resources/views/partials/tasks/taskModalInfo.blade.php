<div id='taskInfo'>
    <h3 class="d-inline-block">{{$task->name}}</h3>
    <button class="btn btn-outline-secondary float-end editButton" type="button" form='editTaskForm'><i class="bi bi-pencil"></i></button>
    @if ($task->due_date)
    <p class="text-muted">Due by: {{$task->getReadableDueDate()}}</p>
    @endif
    <h6 class="text-muted">{{$task->description}}</h6>
</div>