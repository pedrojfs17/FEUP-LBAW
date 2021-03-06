@extends('layouts.app')

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/min/min-style.css') }}">
@endpush

@push('scripts')
  <script src="{{ asset('js/min/min-search.js') }}" defer></script>
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
<div class="container mb-5">
  <div class="row my-4">
    <div class="input-group">
      <input id="search" name="query" type="text" class="form-control" placeholder="Search"
             aria-label="search" aria-describedby="button-search">
      <button class="btn btn-outline-secondary" type="button" id="button-search-projects"><i
          class="bi bi-search"></i></button>
    </div>
  </div>
  <div class="accordion" id="accordionSearch">
    @include('partials.search.searchProjects')
    @include('partials.search.searchTasks')
    @include('partials.search.searchUsers')
  </div>
</div>

@include('partials.helpers.searchHelper')

@endsection
