<div class="my-3 multi-collapse-{{$task->id}}-assign show" id="task{{$task->id}}Assign"
                   aria-expanded="true">
    @include('partials.clientPhoto',['assignees'=>$task->assignees])
</div>