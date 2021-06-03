@extends('layouts.app')

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
@endpush

@section('content')
<div class="container d-flex flex-column justify-content-center my-5">
  <div class="row justify-content-center">
    <a href="{{ route('/') }}" style="width: auto;">
      <img src= {{ asset("images/oversee_blue_txt.svg") }} height="90" alt="company logo">
    </a>
  </div>

  <div class="row justify-content-center mt-5">
    <div class="col-xl-4 col-lg-5 col-md-7">
      <div class="fs-2">Sign up</div>
      <div class="text-muted fs-5">Welcome to Oversee!</div>
      <div class="text-muted fs-5">Have an account already? <a href="{{ route('login') }}" class="text-decoration-none"
                                                               style="color: #00AFB9;">Sign in</a> instead.
      </div>
    </div>
  </div>

  <div class="row justify-content-center my-4">
    <div class="col-xl-4 col-lg-5 col-md-7">
      <form method="POST" action="{{ route('register') }}">
        {{ csrf_field() }}

        @if ($errors->first())
          <div class="alert alert-danger mb-3" role="alert">
            {{ $errors->first() }}
          </div>
        @endif

        <div class="mb-3">
          <label for="inputEmail" class="form-label">Email <span class="text-muted">*</span></label>
          <input type="email" class="form-control" id="inputEmail" value="{{ old('email') }}" name="email" required autofocus>
        </div>
        <div class="mb-3">
          <label for="inputUsername" class="form-label">Username <span class="text-muted">*</span></label>
          <input type="text" class="form-control" id="inputUsername" value="{{ old('username') }}" name="username" required>
        </div>
        <div class="mb-3">
          <label for="inputPassword" class="form-label">Password <span class="text-muted">*</span></label>
          <input type="password" class="form-control" id="inputPassword" name="password" required>
        </div>
        <div class="mb-3">
          <label for="inputPasswordConfirmation" class="form-label">Password Confirmation <span class="text-muted">*</span></label>
          <input type="password" class="form-control" id="inputPasswordConfirmation" name="password_confirmation" required>
        </div>
        <div class="d-grid mt-4">
          <button type="submit" class="btn btn-danger">
            Sign up
          </button>
        </div>
      </form>
    </div>
  </div>
</div>
@endsection
