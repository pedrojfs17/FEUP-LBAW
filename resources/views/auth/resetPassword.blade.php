@extends('layouts.app')

@section('content')
  <div class="container d-flex flex-column justify-content-center my-5">
    <div class="row justify-content-center">
      <a href="{{ route('/') }}" style="width: auto;">
        <img src= {{ asset("images/oversee_blue_txt.svg") }} height="90" alt="company logo">
      </a>
    </div>

    <div class="row justify-content-center mt-5">
      <div class="col-xl-4 col-lg-5 col-md-7">
        <div class="fs-2">Recover Password</div>
        <div class="text-muted fs-5">Please give us your email so we can send you a recovery link!</div>
      </div>
    </div>

    <div class="row justify-content-center my-4">
      <div class="col-xl-4 col-lg-5 col-md-7">
        <form method="POST" action="{{ route('recover_password') }}">
          @csrf
          <input type="hidden" value="{{ $token }}" name="token">

          @if ($errors->first())
            <div class="alert alert-danger mb-3" role="alert">
              {{ $errors->first() }}
            </div>
          @endif

          <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="text" class="form-control" id="email" name="email" required autofocus>
          </div>

          <div class="mb-3">
            <label for="inputPassword" class="form-label">New Password <span class="text-muted">*</span></label>
            <input type="password" class="form-control" id="inputPassword" name="password" required>
          </div>

          <div class="mb-3">
            <label for="inputPasswordConfirmation" class="form-label">New Password Confirmation <span class="text-muted">*</span></label>
            <input type="password" class="form-control" id="inputPasswordConfirmation" name="password_confirmation" required>
          </div>

          <div class="d-grid mt-4">
            <button type="submit" class="btn btn-danger" style="background-color: #ea4c89;">
              Recover Password
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
@endsection
