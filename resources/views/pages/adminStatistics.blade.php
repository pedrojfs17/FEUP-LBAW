@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/script.js') }}" defer></script>
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
  @if ($errors->any())
    <div class="alert alert-danger text-center" role="alert">
      {{ $errors->first() }}
    </div>
  @endif

  @if (session('message') !== null)
    <div class="alert alert-success text-center" role="alert">
      {{ session('message') }}
    </div>
  @endif

  @include('partials.adminNavBar', ['page' => 'statistics'])

  @csrf

  <div class="container-md">
    <div class="d-flex justify-content-between mt-3">
      <div class="col-6 d-flex flex-column">
        <h1 class="mb-3">User Stats</h1>
        <div class="d-flex flex-column justify-content-center flex-grow-1">
          <div class=" d-flex justify-content-around me-4 shadow p-3" style="border-radius: 15px">
            <div class="text-center">
              <h1 class="display-6">{{$total_users}}</h1>
              <h5>Total Users</h5>
            </div>
            <div class="text-center">
              <h1 class="display-6">{{$women}}%</h1>
              <h5>Women</h5>
            </div>
            <div class="text-center">
              <h1 class="display-6">{{$men}}%</h1>
              <h5>Men</h5>
            </div>
          </div>
        </div>
      </div>
      <div class="col-6 px-2 align-items-center">
        <h1 class="mb-3">Top Countries</h1>
        @foreach($countries as $country => $n)
        <div class="d-flex">
          <h5 class="col-3">{{$country}}</h5>
          <div class="progress col-9">
            <div class="progress-bar" role="progressbar" style="width: {{$n}}%;background-color: #00AFB9"
                 aria-valuenow="{{$n}}" aria-valuemin="0" aria-valuemax="100">{{$n}}%
            </div>
          </div>
        </div>
        @endforeach
      </div>
    </div>

  </div>
  <div class="container-md">
    <div class="d-flex justify-content-between mt-3 stats-dashboard ">
      <div class="d-flex flex-column flex-grow-1">

        <div class="row align-items-center">
          <div class="col-lg-12 order-lg-1">
            <h1 class="mb-3">Project Stats</h1>
          </div>
        </div>
        <div class="row align-items-center">
          <div class="col-lg-3 order-lg-3">
            <h1 class="display-6">{{$total_projects}}</h1>
            <h5>Total Projects</h5>
          </div>
          <div class="col-lg-3 order-lg-3">
            <h1 class="display-6">{{$completed_projects}}</h1>
            <h5>Projects completed</h5>
          </div>
          <div class="col-lg-3 order-lg-3">
            <h1 class="display-6">{{$avg_projects}}</h1>
            <h5>Avg Projects/User</h5>
          </div>
          <div class="col-lg-3 order-lg-3">
            <h1 class="display-6">{{$avg_progress}}%</h1>
            <h5>Avg Project Progress</h5>
          </div>
        </div>
      </div>

    </div>

  </div>
@endsection
