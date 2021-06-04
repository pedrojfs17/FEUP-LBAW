<div class="row justify-content-center align-items-begin px-md-5" id='project{{$project->id}}Info'>
    <h3 class="d-inline-block">{{$project->name}}</h3>
    @if ($project->due_date)
    <p class="text-muted">Due by: {{$project->getReadableDueDate()}}</p>
    @endif
    <p class="text-muted">{{$project->description}}</p>
    @if ($project->closed)
    <p class="text-danger">This project has been closed. You can ask one of the owners to reopen it!<p>
    @else
    <p class="text-success">This project is open! Collaborate on it :D</p>
    @endif
</div>
