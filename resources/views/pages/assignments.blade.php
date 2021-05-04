@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/text-bg.js') }}" defer></script>
  <script src="{{ asset('js/carousel.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/overview.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
  @include('partials.projectNavBar', ['page' => 'assignments'])

  <div class="row container-md mx-auto">
    <div class="col-lg-3">
      <div class="card mb-2">
        <div class="card-header bg-secondary text-center text-white ">
          Unassigned
        </div>
        <div class="card-body ">
          <div class="d-grid gap-2 ">
            <button class="btn btn-light text-start " type="button ">Bake</button>
          </div>
        </div>
      </div>
    </div>
    <div class="container col">
      <div class="container-md text-center p-0 m-0">
        <div class="row mx-auto my-auto">
          <div id="cardCarousel"
               class="gx-0 carousel carousel-dark slide w-100 d-flex justify-content-center flex-column flex-lg-row"
               data-bs-interval="false">
            <div class="d-flex justify-content-evenly my-3 d-lg-none">
              <button class="w-auto border-0 bg-transparent" data-bs-target="#cardCarousel" type="button"
                      data-bs-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Previous</span>
              </button>
              <button class="w-auto border-0 bg-transparent" data-bs-target="#cardCarousel" type="button"
                      data-bs-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Next</span>
              </button>
            </div>
            <button class="w-auto border-0 d-none d-lg-block bg-transparent" data-bs-target="#cardCarousel"
                    type="button" data-bs-slide="prev">
              <span class="carousel-control-prev-icon" aria-hidden="true"></span>
              <span class="visually-hidden">Previous</span>
            </button>
            <div class="carousel-inner">
              @foreach ($project->teamMembers as $team_member)
                @include('partials.projectAssignment', ['team_member' => $team_member, 'active' => $loop->first])
              @endforeach
            </div>
            <button class="w-auto border-0 d-none d-lg-block bg-transparent" data-bs-target="#cardCarousel"
                    type="button" data-bs-slide="next">
              <span class="carousel-control-next-icon" aria-hidden="true"></span>
              <span class="visually-hidden">Next</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection