@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/text-bg.js') }}" defer></script>
  <script src="{{ asset('js/drag-and-drop.js') }}" defer></script>
  <script src="{{ asset('js/form-validation.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  <script src="{{ asset('js/tasks.js') }}" defer></script>
  <script src="{{ asset('js/addmembers.js') }}" defer></script>
  <script src="{{ asset('js/taskForm.js') }}" defer></script>
  <script src="{{ asset('js/comments.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/overview.css') }}">
  <link rel="stylesheet" href="{{ asset('css/drag-and-drop.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
  @include('partials.projectNavBar', ['page' => 'status'])

  <div class="container-md pb-5">
    <div class="row">
      @csrf
      @foreach ($status_enum as $status)
        @include('partials.statusCard', ['status' => $status, 'tasks' => $tasks])
      @endforeach
    </div>
  </div>

  <div class="modal-container"></div>
@endsection
