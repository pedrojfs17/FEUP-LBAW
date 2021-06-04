@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/text-bg.js') }}" defer></script>
  <script src="{{ asset('js/form-validation.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  @if (!$project->closed && $role != 'Reader')
  <script src="{{ asset('js/addmembers.js') }}" defer></script>
  @endif
  <script src="{{ asset('js/taskForm.js') }}" defer></script>
  <script src="{{ asset('js/comments.js') }}" defer></script>
  <script src="{{ asset('js/tasks.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/overview.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection


@section('content')
  @include('partials.projectNavBar', ['page' => 'overview'])
  @include('partials.tasks.taskFilter')

  <div class="mb-5 container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start" id="overview">
    @include('partials.projectTasks',['tasks'=>$tasks])

    @if (!$project->closed && $role != 'Reader')
    <div class="card task-card m-2 border-3 border-secondary d-flex align-items-center justify-content-center"
         style="background-color: #efefef; border-style: dashed; min-height: 200px" id="createTaskCard">
      <i class="bi bi-plus-circle text-muted fs-2"></i>
      <a data-bs-toggle="offcanvas" href="#createTask" aria-controls="createTask" role="button" class="stretched-link p-0"></a>
    </div>
    @include('partials.projectCreateElements')
    @endif
  </div>

  @include('partials.helpers.overviewHelper')
@endsection
