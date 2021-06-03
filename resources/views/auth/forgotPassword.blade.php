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
        <div class="fs-2">Recover Password</div>
        <div class="text-muted fs-5">Please provide us your email so we can send you a recovery link!</div>
      </div>
    </div>

    <div class="row justify-content-center my-4">
      <div class="col-xl-4 col-lg-5 col-md-7">
        <form method="POST" action="{{ route('forgot_password') }}">
          @csrf

          @if (Session::has('message'))
            <div class="alert alert-success mb-3" role="alert">
              {{ Session::get('message') }}
            </div>
          @endif

          @if ($errors->first())
            <div class="alert alert-danger mb-3" role="alert">
              {{ $errors->first() }}
            </div>
          @endif

          <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="text" class="form-control" id="email" name="email" required autofocus>
          </div>
          <div class="d-grid mt-4">
            <button type="submit" class="btn btn-danger">
              Recover Password
            </button>
            <a href="{{ URL::previous() }}" role="button" class="btn btn-outline-secondary mt-3">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
@endsection

