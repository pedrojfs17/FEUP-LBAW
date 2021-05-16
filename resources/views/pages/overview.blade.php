@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/text-bg.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  <script src="{{ asset('js/tags.js') }}" defer></script>
  <script src="{{ asset('js/deleteTask.js') }}" defer></script>
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
  @include('partials.taskFilter',['project' => $tasks->first()->project()->first()])

  <div class="mb-5 container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start" id="overview">
    @include('partials.projectTasks',['tasks'=>$tasks])
  </div>

  @include('partials.projectCreateElements')
@endsection
