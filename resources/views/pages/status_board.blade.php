@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/min/min-text-bg.js') }}" defer></script>
  <script src="{{ asset('js/min/min-drag-and-drop.js') }}" defer></script>
  <script src="{{ asset('js/min/min-form-validation.js') }}" defer></script>
  <script src="{{ asset('js/min/min-ajax.js') }}" defer></script>
  <script src="{{ asset('js/min/min-tasks.js') }}" defer></script>
  <script src="{{ asset('js/min/min-taskForm.js') }}" defer></script>
  <script src="{{ asset('js/min/min-comments.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/min/min-style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/min/min-overview.css') }}">
  <link rel="stylesheet" href="{{ asset('css/min/min-drag-and-drop.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
  @include('partials.project.projectNavBar', ['page' => 'status'])

  <div class="container-md pb-5">
    <div class="row">
      @csrf
      @foreach ($status_enum as $status)
        @include('partials.project.statusCard', ['status' => $status, 'tasks' => $tasks])
      @endforeach
    </div>
  </div>

  <div class="modal-container"></div>

  @include('partials.helpers.statusHelper')
@endsection
