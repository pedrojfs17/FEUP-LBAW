<div id="task{{$task->id}}UpdateAssign" class="collapse mb-3 multi-collapse-{{$task->id}}-assign"
                   aria-expanded="false">
    <form data-id="task{{$task->id}}Assign"
            data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/assignment">
        @csrf
        <select class="form-control assign-selection" multiple="multiple" name="assign"
                id="assign-selection-{{$task->id}}">
        @foreach ($task->project()->first()->teamMembers as $team_member)
            @if($task->assignees()->where('id',$team_member->id)->count()!==0)
            <option value="{{$team_member->id}}"
                    selected="selected">{{$team_member->account->username}}</option>
            @else
            <option value="{{$team_member->id}}">{{$team_member->account->username}}</option>
            @endif
        @endforeach
        </select>
        <button type="submit" class="d-none"></button>
    </form>
</div>