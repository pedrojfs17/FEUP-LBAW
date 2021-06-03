<div id="task{{$task->id}}UpdateSubTask" class="collapse mb-3 multi-collapse-{{$task->id}}-sub"
                 aria-expanded="false">
    <form data-id="task{{$task->id}}SubTask"
        data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/subtask">
    @csrf
    <select class="form-control subtask-selection" multiple="multiple" name="subtask"
            id="subtask-selection-{{$task->id}}">
        @foreach ($task->project()->first()->tasks as $subtask)
        @if ($task->id == $subtask->id)
            @continue
        @elseif($task->subtasks()->where('id',$subtask->id)->count()!==0)
            <option value="{{$subtask->id}}" selected="selected">{{$subtask->name}}</option>
        @else
            <option value="{{$subtask->id}}">{{$subtask->name}}</option>
        @endif
        @endforeach
    </select>
    <button type="submit" class="d-none"></button>
    </form>
</div>