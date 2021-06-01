<div class="row justify-content-center align-items-begin px-5" id='project{{$project->id}}Info'>
    <h3 class="d-inline-block">{{$project->name}}</h3>
    @if ($project->due_date)
    <p class="text-muted">Due by: {{$project->getReadableDueDate()}}</p>
    @endif
    <h6 class="text-muted">{{$project->description}}</h6>
</div>