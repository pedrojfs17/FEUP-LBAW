@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/text-bg.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
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

  <div class="mb-5 container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start" id="overview">
    @foreach ($tasks as $task)
        @include('partials.task', ['task' => $task])
        @include('partials.taskModal', ['task' => $task])
    @endforeach
  </div>

  @include('partials.projectCreateElements')
@endsection
