<div class="card my-2" role="button" @if ($project->closed) style='background-color: #ced4da55;' @endif>
  <div class="card-body">
    <h5 class="card-title"><a class="d-flex align-items-center stretched-link text-decoration-none text-reset text-wrap text-capitalize" href="{{ route('project.overview', ['project' => $project->id]) }}">{{ $project->name }}
      @if ($project->closed)
      <i class="bi bi-lock-fill fa-xs ms-1"></i>
      @endif
    </a></h5>
    <div class="row align-items-center">
      <div class="col-lg-3 col-md-3">
        <ul class="position-relative avatar-overlap d-none d-md-block" style="width: max-content; z-index: 1">
          @foreach ($project->teamMembers as $member)
            <li class="avatar-overlap-item" style="z-index: {{ 3 - $loop->iteration }}"><img class="rounded-circle" src="{{ url($member->avatar) }}" width="40" height="40" alt="avatar"></li>
            @if ($loop->iteration == 3)
              @break
            @endif
          @endforeach
          @if ($project->getMemberCount() > 3)
          <li class="avatar-overlap-item" style="z-index: -1"><div class="number-circle">+{{ $project->getMemberCount() - 3 }}</div></li>
          @endif
        </ul>
      </div>
      @if ($project->due_date != null)
      <div class="col-lg-3 col-md-3 text-muted">Due Date: {{ $project->getReadableDueDate() }}</div>
      @else
      <div class="col-lg-3 col-md-3 text-muted"></div>
      @endif
      <div class="col-lg-4 offset-lg-2 col-md-4 offset-md-2 text-end text-muted">
        @if ($project->completion === 100) Completed @else Progress ({{ $project->completion }}%) @endif
        <div class="progress">
          <div class="progress-bar bg-success" role="progressbar" style="width: {{ $project->completion }}%" aria-valuenow="{{ $project->completion }}" aria-valuemin="0" aria-valuemax="100"></div>
        </div>
      </div>
    </div>
  </div>
</div>
