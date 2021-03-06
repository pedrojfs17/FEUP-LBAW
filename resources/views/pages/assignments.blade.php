@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/min/min-text-bg.js') }}" defer></script>
  <script src="{{ asset('js/min/min-form-validation.js') }}" defer></script>
  <script src="{{ asset('js/min/min-carousel.js') }}" defer></script>
  <script src="{{ asset('js/min/min-ajax.js') }}" defer></script>
  <script src="{{ asset('js/min/min-taskForm.js') }}" defer></script>
  <script src="{{ asset('js/min/min-comments.js') }}" defer></script>
  <script src="{{ asset('js/min/min-tasks.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/min/min-style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/min/min-overview.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
  @include('partials.project.projectNavBar', ['page' => 'assignments'])

  <div class="row container-md mx-auto">
    <div class="col-lg-3">
      <div class="card mb-2">
        <div class="card-header bg-secondary text-center text-white ">
          Unassigned
        </div>
        <div class="card-body ">
          <div class="d-grid gap-2 ">
            @foreach ($tasks as $task)
              @if (count($task->assignees) == 0)
                <button type="button" style="background-color: #e7e7e7" class="btn text-start subtask-{{ str_replace(' ', '-', strtolower($task->task_status)) }} open-task" data-target="task{{ $task->id }}Modal" data-href="/api/project/{{ $task->project }}/task/{{ $task->id }}">{{ $task->name }}</button>
              @endif
            @endforeach
          </div>
        </div>
      </div>
    </div>
    <div class="container col">
      <div class="container-md text-center p-0 m-0">
        <div class="row mx-auto my-auto">
          @if (count($project->teamMembers) > 3)
          <div id="cardCarousel"
               class="gx-0 carousel carousel-dark slide w-100 d-flex justify-content-center flex-column flex-lg-row"
               data-bs-interval="false">
            <div class="d-flex justify-content-evenly my-3 d-lg-none">
              <button class="w-auto border-0 bg-transparent" data-bs-target="#cardCarousel" type="button"
                      data-bs-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Previous</span>
              </button>
              <button class="w-auto border-0 bg-transparent" data-bs-target="#cardCarousel" type="button"
                      data-bs-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Next</span>
              </button>
            </div>
            <button class="w-auto border-0 d-none d-lg-block bg-transparent" data-bs-target="#cardCarousel"
                    type="button" data-bs-slide="prev" style="height: max-content">
              <span class="carousel-control-prev-icon" aria-hidden="true"></span>
              <span class="visually-hidden">Previous</span>
            </button>
            <div class="carousel-inner">
              @foreach ($project->teamMembers as $team_member)
                @include('partials.project.projectAssignment', ['team_member' => $team_member, 'active' => $loop->first, 'carousel' => true])
              @endforeach
            </div>
            <button class="w-auto border-0 d-none d-lg-block bg-transparent" data-bs-target="#cardCarousel"
                    type="button" data-bs-slide="next" style="height: max-content">
              <span class="carousel-control-next-icon" aria-hidden="true"></span>
              <span class="visually-hidden">Next</span>
            </button>
          </div>
          @else
          <div class='d-flex'>
              @foreach ($project->teamMembers as $team_member)
                @include('partials.project.projectAssignment', ['team_member' => $team_member, 'carousel' => false])
              @endforeach
          </div>
          @endif
        </div>
      </div>
    </div>
  </div>

  <div class="modal-container"></div>

  @include('partials.helpers.assignmentsHelper')
@endsection
