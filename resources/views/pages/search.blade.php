@extends('layouts.app')

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
@endpush

@push('scripts')
  <script src="{{ asset('js/search.js') }}" defer></script>
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
<div class="container">
  <div class="row my-4">
    <div class="input-group">
      <input id="search" name="query" type="text" class="form-control" placeholder="Search"
             aria-label="search" aria-describedby="button-search">
      <button class="btn btn-outline-secondary" type="button" id="button-search-projects"><i
          class="bi bi-search"></i></button>
    </div>
  </div>
  <div class="accordion" id="accordionSearch">
    @include('partials.searchProjects')
    @include('partials.searchTasks')
    @include('partials.searchUsers')
  </div>
</div>
@endsection
