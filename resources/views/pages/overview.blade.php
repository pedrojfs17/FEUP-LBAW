@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/min/min-text-bg.js') }}" defer></script>
  <script src="{{ asset('js/min/min-form-validation.js') }}" defer></script>
  <script src="{{ asset('js/min/min-ajax.js') }}" defer></script>
  @if (!$project->closed && $role != 'Reader')
  <script src="{{ asset('js/min/min-addmembers.js') }}" defer></script>
  @endif
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
  @include('partials.project.projectNavBar', ['page' => 'overview'])
  @include('partials.tasks.taskFilter')

  <div class="mb-5 container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start" id="overview">
    @include('partials.project.projectTasks',['tasks'=>$tasks])

    @if (!$project->closed && $role != 'Reader')
    <div class="card task-card m-2 border-3 border-secondary d-flex align-items-center justify-content-center"
         style="background-color: #efefef; border-style: dashed; min-height: 200px" id="createTaskCard">
      <i class="bi bi-plus-circle text-muted fs-2"></i>
      <a data-bs-toggle="offcanvas" href="#createTask" aria-controls="createTask" role="button" class="stretched-link p-0"></a>
    </div>
    @include('partials.project.projectCreateElements')
    @endif
  </div>

  @include('partials.helpers.overviewHelper')
@endsection
