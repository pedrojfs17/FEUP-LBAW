<div id='task{{$task->id}}Info'>
    <h3 class="d-inline-block">{{$task->name}}</h3>
    @if (!$task->project()->first()->closed && $role != 'Reader')
    <button class="btn btn-outline-secondary float-end editButton" type="button" form='editTask{{$task->id}}Form'><i class="bi bi-pencil"></i></button>
    @endif
    @if ($task->due_date)
    <p class="text-muted">Due by: {{$task->getReadableDueDate()}}</p>
    @endif
    <h6 class="text-muted">{{$task->description}}</h6>
</div>