@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/drag-and-drop.js') }}" defer></script>
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
  @include('partials.projectNavBar', ['page' => 'status-board'])

  <div class="container-md pb-5">
    <div class="row">
      @csrf
      @foreach ($status_enum as $status)
        @include('partials.statusCard', ['status' => $status, 'tasks' => $tasks])
      @endforeach
    </div>
  </div>

  @each('partials.taskModal', $tasks, 'task')
@endsection
