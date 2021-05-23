<h5 class=" d-inline-block mr-3">Checklist</h5>
<p
  class=" d-inline-block text-secondary">@if (count($task->checkListItems) > 0) {{ count($task->checklistItems->where('completed', true)) / count($task->checklistItems) * 100 }}
  % @else 0% @endif</p>
<div class="progress" style="height:5px;">
  @if (count($task->checkListItems))
    <div class="progress-bar" role="progressbar"
         style="width: {{ count($task->checklistItems->where('completed', true)) / count($task->checklistItems) * 100 }}%; height:5px; background-color:green;"
         aria-valuenow="{{ count($task->checklistItems->where('completed', true)) / count($task->checklistItems) * 100 }}"
         aria-valuemin="0" aria-valuemax="100">
    </div>
  @else
    <div class="progress-bar" role="progressbar" style="width: 0; height:5px; background-color:green;"
         aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
  @endif
</div>
<div class="d-grid gap-2 my-3">
  @csrf
  <div class="checklist-items" >
    @foreach ($task->checklistItems()->get()->reverse() as $item)
      <div class="form-check checklist-item" id="{{$item->id}}" data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/checklist/{{$item->id}}" data-id="task{{$task->id}}CheckList">
        <label class="form-check-label">
          {{$item->item_text}}
          <input class="form-check-input" type="checkbox" @if ($item->completed) checked @endif>
        </label>
        <a class="delete text-muted float-end delete-item" ><i class="bi bi-trash-fill"></i></a>
      </div>
    @endforeach
  </div>
  <form id="addItem" data-href="/api/project/{{$task->project()->first()->id}}/task/{{$task->id}}/checklist" data-id="task{{$task->id}}CheckList">
    <label>
      <input type="text" class="checklist-input" name="new_item" placeholder="Insert new item...">
    </label>
    <input type="submit" class="d-none">
  </form>
</div>
