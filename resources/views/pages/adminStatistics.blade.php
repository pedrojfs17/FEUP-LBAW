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
  @include('partials.admin.adminNavBar', ['page' => 'statistics'])

  @csrf

  <div class="container-md">
    <div class="d-flex flex-column flex-md-row justify-content-between mt-3">
      <div class="col-md-6 d-flex flex-column">
        <h1 class="mb-3">User Stats</h1>
        <div class="d-flex flex-column justify-content-center flex-grow-1">
          <div class=" d-flex flex-wrap justify-content-around m-sm-4 mb-4 ms-0 shadow p-3" style="border-radius: 15px">
            <div class="text-center mx-2">
              <h1 class="display-6">{{$total_users}}</h1>
              <h5>Total Users</h5>
            </div>
            <div class="text-center mx-2">
              <h1 class="display-6">{{$women}}%</h1>
              <h5>Women</h5>
            </div>
            <div class="text-center mx-2">
              <h1 class="display-6">{{$men}}%</h1>
              <h5>Men</h5>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-6 px-2 align-items-center">
        <h1 class="mb-3">Top Countries</h1>
        @foreach($countries as $country => $n)
        <div class="d-flex mb-2 align-items-center">
          <h5 class="col-4 text-truncate me-2 mb-0">{{$country}}</h5>
          <div class="progress col-8 position-relative" data-bs-toggle="tooltip" data-bs-placement="top" title="{{$n}}%">
            <div class="progress-bar" role="progressbar" style="width: {{$n}}%;background-color: #00AFB9"
                 aria-valuenow="{{$n}}" aria-valuemin="0" aria-valuemax="100">
            </div>
          </div>
        </div>
        @endforeach
      </div>
    </div>

  </div>
  <div class="container-md">
    <div class="d-flex justify-content-between mt-3">
      <div class="d-flex flex-column flex-grow-1">

        <div class="row align-items-center">
          <div class="col-lg-12 order-lg-1">
            <h1 class="mb-3">Project Stats</h1>
          </div>
        </div>
        <div class="d-flex flex-wrap align-content-stretch justify-content-between">
          <div class="" style="width: 200px">
            <h1 class="display-6">{{$total_projects}}</h1>
            <h5>Total Projects</h5>
          </div>
          <div class="" style="width: 200px">
            <h1 class="display-6">{{$completed_projects}}</h1>
            <h5>Projects completed</h5>
          </div>
          <div class="" style="width: 200px">
            <h1 class="display-6">{{$avg_projects}}</h1>
            <h5>Avg. Projects/User</h5>
          </div>
          <div class="" style="width: 200px">
            <h1 class="display-6">{{$avg_progress}}%</h1>
            <h5>Avg. Project Progress</h5>
          </div>
        </div>
      </div>

    </div>

  </div>
@endsection
