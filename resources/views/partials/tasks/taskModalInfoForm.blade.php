<form id='editTaskForm' action='../../api/project/{{$task->project}}/task/{{$task->id}}' class='d-none' data-info='taskInfo'>
    @csrf
    <label for="name" class="form-label mb-1">Name</label>
    <span class='d-flex'>
        <input type='text' placeholder='{{$task->name}}' value='{{$task->name}}' class='form-control' name='name'>
        <button class="btn btn-outline-secondary float-end mx-1 cancelButton" type="button"><i class="bi bi-x fa-lg"></i></button>
        <button class="btn btn-outline-secondary float-end saveButton" type="button"><i class="bi bi-check fa-lg"></i></button>
    </span>
    <label for="due_date" class="form-label my-1">Due date</label>
    @if ($task->due_date)
    <input type="date" value="{{(new DateTime($task->due_date))->format('Y-m-d')}}" placeholder="{{(new DateTime($task->due_date))->format('Y-m-d')}}" class="form-control" name="due_date">
    @else
    <input type="date" value="" placeholder="" class="form-control" name="due_date">
    @endif
    <label for="description" class="form-label my-1">Description</label>
    <textarea type='text' placeholder='{{$task->description}}' class='form-control' name='description'>{{$task->description}}</textarea>
</form>