<nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="tasks{{$task->id}}ModalLabel">
    <ol class="my-0 breadcrumb text-muted">
    <li class="breadcrumb-item">
        <a style="cursor: pointer; font-weight: bolder" data-bs-dismiss="modal">Project</a>
    </li>
    @if ($task->hasParent())
        <li class="breadcrumb-item" aria-current="page">
        <a class="open-task remove-anchor-css" style="cursor: pointer; font-weight: bolder" data-target="#task{{$task->parent}}Modal"
            data-href="/api/project/{{ $task->project }}/task/{{ $task->parent }}" data-bs-dismiss="modal">{{$task->parent()->first()->name}}</a>
        </li>
    @endif
    <li class="breadcrumb-item active" aria-current="page">{{$task->name}}</li>
    </ol>
</nav>