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
      <div class="fs-2">Sign in</div>
      <div class="text-muted fs-5">Good to see you again!</div>
      <div class="text-muted fs-5">New to Oversee? <a href="{{ route('register') }}" class="text-decoration-none"
                                                      style="color: #00AFB9;">Sign up</a> instead.
      </div>
    </div>
  </div>

  <div class="row justify-content-center my-4">
    <div class="col-xl-4 col-lg-5 col-md-7">
      <form method="POST" action="{{ route('login') }}">
        {{ csrf_field() }}

        @if ($errors->first())
          <div class="alert alert-danger mb-3" role="alert">
            {{ $errors->first() }}
          </div>
        @endif

        <div class="mb-3">
          <label for="username" class="form-label">Username</label>
          <input type="text" class="form-control" id="username" value="{{ old('username') }}" name="username" required autofocus>
        </div>
        <div class="mb-3">
          <label for="password" class="form-label">Password</label>
          <input type="password" class="form-control" id="password" name="password" required>
        </div>
        <div class="d-grid mt-4">
          <button type="submit" class="btn btn-danger">
            Sign in
          </button>
          <div class="text-center mt-2">
            <a href="{{ route('forgot_password') }}" style="color: #00AFB9;">Forgot Password</a>
          </div>
        </div>
      </form>

      <hr>

      <div class="d-grid gap-2">
        <a href="{{ route('auth.google') }}" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-google me-2"></i>Sign
          in with Google</a>
      </div>
    </div>
  </div>
</div>
@endsection

