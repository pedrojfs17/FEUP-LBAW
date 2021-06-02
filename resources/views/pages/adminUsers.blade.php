@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/script.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  <script src="{{ asset('js/administration.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/overview.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
  @include('partials.adminNavBar', ['page' => 'users'])
  @csrf
  <div class="container mb-5">
    <h4 class="text-muted mt-3">Manage Users</h4>
    <hr>
    <div class="row mb-3">
      <div class="col-lg-8 col-md-8 d-flex">
        <div class="input-group">
          <input id="searchUsers" name="query" type="text" class="form-control" placeholder="Find Users"
                 aria-label="Find Users" aria-describedby="button-search">
          <button class="btn btn-outline-secondary" type="button" id="button-search-users"><i
              class="bi bi-search"></i></button>
        </div>
        <button class="btn btn-light mx-1" type="button" id="button-filter-users" data-bs-toggle="modal" data-bs-target="#userFilterModal"><i
            class="text-muted bi bi-funnel-fill"></i></button>
      </div>
    </div>
    <div class="d-flex justify-content-center my-3" id="usersSpinner">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
    <div id="users">
    </div>
  </div>

  @include('partials.userFilterModal')
@endsection
