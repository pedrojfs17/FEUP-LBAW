<div class="flex-wrap gap-2 my-2 mt-auto multi-collapse-{{$task->id}} show" id="task{{$task->id}}Tags" aria-expanded="true">
    @each('partials.tasks.tag', $task->tags, 'tag')
</div>