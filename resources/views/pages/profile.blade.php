@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/profile.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/ms-form.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection


@section('content')
  <div class="container">
    <div class="row align-items-center mt-5">
      <h1><a class="fs-4 me-4" href="{{ route('dashboard') }}"><i class="bi bi-chevron-left"></i></a>Profile</h1>
    </div>

    <hr>

    <div class="row justify-content-around mt-5">
      <div class="col-lg-3 col-md-6 col-sm-6 d-flex align-items-center justify-content-center">
        <img src="{{ url($client->avatar) }}" alt="Avatar" class="img-fluid mx-auto d-block rounded-circle">
      </div>
      <div class="col-lg-4 align-items-center justify-content-center">
        <form>
          <label for="usernameInput" class="form-label">Username</label>
          <div class="input-group mb-3">
            <input type="text" placeholder="{{$client->account->username}}" class="form-control" id="usernameInput" disabled>
            <button class="btn btn-outline-secondary" type="button" id="button-editUsername"><i
                class="bi bi-pencil"></i></button>
          </div>

          <label for="nameInput" class="form-label">Full Name</label>
          <div class="input-group mb-3">
            <input type="text" placeholder="{{$client->fullname }}" class="form-control" id="nameInput" disabled>
            <button class="btn btn-outline-secondary" type="button" id="button-editName"><i
                class="bi bi-pencil"></i></button>
          </div>

          <label for="emailInput" class="form-label">Email</label>
          <div class="input-group mb-3">
            <input type="email" placeholder="{{$client->account->email }}" class="form-control" id="emailInput"
                   disabled>
            <button class="btn btn-outline-secondary" type="button" id="button-editEmail"><i
                class="bi bi-pencil"></i></button>
          </div>

          <label for="companyInput" class="form-label">Company</label>
          <div class="input-group mb-3">
            <input type="text" placeholder="{{$client->company}}" class="form-control" id="companyInput" disabled>
            <button class="btn btn-outline-secondary" type="button" id="button-editCompany"><i
                class="bi bi-pencil"></i></button>
          </div>
        </form>
      </div>
    </div>

    <div class="row align-items-center mt-5">
      <h4>Change Password</h4>
    </div>

    <hr>

    <div class="row justify-content-center align-items-begin">
      <div class="col-lg-4">
        <label for="inputPassword6" class="col-form-label">Old Password <span
            class="text-muted">*</span></label>
        <input type="password" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
        <span id="passwordHelpInline" class="form-text">
                Must be 8-20 characters long.
            </span>
      </div>
      <div class="col-lg-4">
        <label for="inputPassword6" class="col-form-label">New Password <span
            class="text-muted">*</span></label>
        <input type="password" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
        <span id="passwordHelpInline" class="form-text">
                Must be 8-20 characters long.
            </span>
      </div>
      <div class="col-lg-4">
        <label for="inputPassword6" class="col-form-label">Repeat New Password <span class="text-muted">*</span></label>
        <input type="password" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
        <span id="passwordHelpInline" class="form-text">
                Must be 8-20 characters long.
            </span>
        <div class="d-grid pt-4 gap-2">
          <button type="button" class="btn btn-dark">Change Password</button>
        </div>
      </div>
    </div>
  </div>
@endsection
