<form id='editTask{{$task->id}}Form' action='../../api/project/{{$task->project}}/task/{{$task->id}}' class='d-none validate-form' data-info='task{{$task->id}}Info'>
    @csrf
    <label for="name" class="form-label mb-1">Name</label>
    <div class='input-group has-validation'>
        <input type='text' placeholder='{{$task->name}}' value='{{$task->name}}' class='form-control' name='name' aria-describedby="inputNameFeedback" required>
        <button class="btn btn-outline-secondary cancelButton" type="button"><i class="bi bi-x fa-lg"></i></button>
        <button class="btn btn-outline-secondary saveButton" type="button"><i class="bi bi-check fa-lg"></i></button>
        <div class="invalid-feedback flex-shrink-0" id="inputNameFeedback"></div>
    </div>
    
    <label for="due_date" class="form-label my-1">Due date</label>
    <div class='input-group has-validation'>
        @if ($task->due_date)
        <input type="date" value="{{(new DateTime($task->due_date))->format('Y-m-d')}}" placeholder="{{(new DateTime($task->due_date))->format('Y-m-d')}}" aria-describedby="inputDateFeedback" class="form-control" name="due_date">
        @else
        <input type="date" value="" placeholder="" aria-describedby="inputDateFeedback" class="form-control" name="due_date">
        @endif
        <button class="btn btn-outline-secondary clearButton" type="button"><i class="bi bi-x-circle fa-sm"></i></button>
        <div class="invalid-feedback" id="inputDateFeedback"></div>
    </div>

    <label for="description" class="form-label my-1">Description</label>
    <textarea type='text' placeholder='{{$task->description}}' aria-describedby="inputDescriptionFeedback" class='form-control' name='description'>{{$task->description}}</textarea>
    <div class="invalid-feedback flex-shrink-0" id="inputDescriptionFeedback"></div>
</form>