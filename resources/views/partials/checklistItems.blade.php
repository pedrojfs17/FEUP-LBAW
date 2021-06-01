<h5 class="d-inline-block">Checklist</h5>
<span class="d-inline-block float-end text-secondary">
  {{ $task->getChecklistCompletion() }}%
</span>
<div class="progress" style="height:5px;">
  <div class="progress-bar" role="progressbar"
       style="width: {{ $task->getChecklistCompletion() }}%; height:5px; background-color:green;"
       aria-valuenow="{{ $task->getChecklistCompletion() }}"
       aria-valuemin="0" aria-valuemax="100">
  </div>
</div>
<div class="d-grid gap-2 my-3">
  @csrf
  <div class="checklist-items" >
    @foreach ($task->checklistItems()->get()->reverse() as $item)
      <div class="form-check checklist-item" id="{{$item->id}}" data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/checklist/{{$item->id}}" data-id="task{{$task->id}}CheckList">
        <label class="form-check-label">
          {{$item->item_text}}
          <input class="form-check-input" type="checkbox" @if ($item->completed) checked @endif @if ($role == 'Reader') disabled @endif>
        </label>
        @if ($role != 'Reader')
        <a class="delete text-muted float-end delete-item" ><i class="bi bi-trash-fill"></i></a>
        @endif
      </div>
    @endforeach
  </div>
  @if ($role != 'Reader')
  <form id="addItem" data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/checklist" data-id="task{{$task->id}}CheckList">
    <label>
      <input type="text" class="checklist-input" name="new_item" placeholder="Insert new item...">
    </label>
    <input type="submit" class="d-none">
  </form>
  @endif
</div>
