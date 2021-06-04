<form class="row justify-content-center align-items-begin px-md-5 validate-form edit-form-d">
    @csrf
    <label for="name" class="form-label">Name</label>
    <div class="input-group mb-3 has-validation">
    <input type="text" placeholder="{{ $project->name }}" value="{{ $project->name }}" aria-describedby="inputNameFeedback" class="form-control" name="name" disabled>
    <div class="invalid-feedback flex-shrink-0" id="inputNameFeedback"></div>
    </div>

    <label for="description" class="form-label">Description</label>
    <div class="input-group mb-3 has-validation">
    <textarea class="form-control" name="description" style="height: 8em;" disabled aria-describedby="inputDescriptionFeedback" placeholder='{{ $project->description }}'>{{ $project->description }}</textarea>
    <div class="invalid-feedback flex-shrink-0" id="inputDescriptionFeedback"></div>
    </div>

    <label for="due_date" class="form-label">Due Date</label>
    <div class="input-group mb-3 has-validation">
    @if ($project->due_date)
    <input disabled type="date" value="{{(new DateTime($project->due_date))->format('Y-m-d')}}" placeholder="{{(new DateTime($project->due_date))->format('Y-m-d')}}" aria-describedby="inputDateFeedback" class="form-control" name="due_date">
    @else
    <input disabled type="date" value="" placeholder="" aria-describedby="inputDateFeedback" class="form-control" name="due_date">
    @endif
    <button class="btn btn-outline-secondary clearButton" type="button"><i class="bi bi-x-circle fa-sm"></i></button>
    <div class="invalid-feedback" id="inputDateFeedback"></div>
    </div>
    @include('partials.project.projectStatus')
</form>
