<div id="task{{$task->id}}UpdateWaiting" class="collapse mb-3 multi-collapse-{{$task->id}}-wait"
                 aria-expanded="false">
    <form data-id="task{{$task->id}}Waiting"
        data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/waiting_on">
    @csrf
    <select class="form-control waiting-selection" multiple="multiple" name="waiting"
            id="waiting-selection-{{$task->id}}">
        @foreach ($task->project()->first()->tasks as $task_wait)
        @if ($task->id == $task_wait->id)
            @continue
        @elseif($task->waitingOn()->where('id',$task_wait->id)->count()!==0)
            <option value="{{$task_wait->id}}" selected="selected">{{$task_wait->name}}</option>
        @else
            <option value="{{$task_wait->id}}">{{$task_wait->name}}</option>
        @endif
        @endforeach
    </select>
    <button type="submit" class="d-none"></button>
    </form>
</div>