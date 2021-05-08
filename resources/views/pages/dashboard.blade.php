@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/ms-form.js') }}" defer></script>
  <script src="{{ asset('js/dashboard.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/ms-form.css') }}">
  <link rel="stylesheet" href="{{ asset('css/overview.css') }}">
  <link rel="stylesheet" href="{{ asset('css/paginator.css') }}">
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

  <div class="container mb-5">
    <ul class="nav nav-tabs mb-3 mt-sm-5" id="dashboardNav" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active fs-3" id="projects-btn" data-bs-toggle="tab"
                data-bs-target="#projects-tab" type="button" role="tab" aria-controls="projects-tab"
                aria-selected="true">Projects
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link fs-3" id="stats-btn" data-bs-toggle="tab" data-bs-target="#stats-tab"
                type="button" role="tab" aria-controls="stats-tab" aria-selected="false">Statistics
        </button>
      </li>
    </ul>
    <div class="tab-content" id="dashboardContent">
      <div class="tab-pane fade show active" id="projects-tab" role="tabpanel" aria-labelledby="projects-tab">
        <div class="row mb-3">
          <div class="col-lg-8 col-md-8 d-flex">
            <div class="input-group">
              <input id="searchProjects" name="query" type="text" class="form-control" placeholder="Find Projects"
                     aria-label="Find Projects" aria-describedby="button-search">
              <button class="btn btn-outline-secondary" type="button" id="button-search-projects"><i
                  class="bi bi-search"></i></button>
            </div>
            <button class="btn btn-light mx-1" type="button" id="button-filter-projects"><i
                class="text-muted bi bi-funnel-fill"></i></button>
          </div>
          <div class="d-flex col-lg-4 col-md-4 col-sm-12 mt-3 mt-md-0">
            <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0"
                    style="background-color: #ea4c89;" data-bs-toggle="modal"
                    data-bs-target="#createProjectModal">+ New Project
            </button>
          </div>
        </div>
        <div class="d-flex justify-content-center my-3" id="projectsSpinner">
          <div class="spinner-border" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
        <div id="projects">
        </div>
      </div>

      <div class="tab-pane fade" id="stats-tab" role="tabpanel" aria-labelledby="stats-tab">
        <div class="row mb-3">
          <div class="col-lg-8 col-md-8 d-flex">
            <div class="input-group">
              <input type="text" class="form-control" placeholder="Find Accounts"
                     aria-label="Find Accounts" aria-describedby="button-search-acc" disabled>
              <button class="btn btn-outline-secondary" type="button" id="button-search-acc"><i
                  class="bi bi-search"></i></button>
            </div>
            <button class="btn btn-light mx-1" type="button" id="button-filter-acc"><i
                class="text-muted bi bi-funnel-fill"></i></button>
          </div>
          <div class="d-flex col-lg-4 col-md-4 col-sm-12 mt-3 mt-md-0">
            <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0"
                    style="background-color: #ea4c89;" data-bs-toggle="modal"
                    data-bs-target="#connectAccountModal">+ Connect Account
            </button>
          </div>
        </div>
        <div class="d-flex flex-wrap align-content-start justify-content-center justify-content-md-between">
          {{--<div class="card m-1 border" style="max-width: 300px;">
            <div class="row gx-0 align-items-center">
              <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
              </div>
              <div class="col-md-6">
                <div class="card-body">
                  <h5 class="card-title fw-bold fs-4">nenieats</h5>
                  <p class="card-text"><i class="bi bi-instagram"></i> Instagram</p>
                </div>
              </div>
            </div>
            <div class="row gx-0 mb-2 justify-content-center align-items-center">
              <div class="d-flex justify-content-center fs-2">
                <i class="bi bi-person"></i> 1.7k
                <span class="badge bg-light text-success fs-6 px-0 py-0">
                                    <i class="bi bi-chevron-double-up"></i>23
                                </span>
              </div>
            </div>
            <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;"
                    data-bs-toggle="modal" data-bs-target="#statisticsModal">See More
            </button>
          </div>--}}

          {{--<div class="card m-1 border" style="max-width: 300px;">
            <div class="row gx-0 align-items-center">
              <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
              </div>
              <div class="col-md-6">
                <div class="card-body">
                  <h5 class="card-title fw-bold fs-4">nenieats</h5>
                  <p class="card-text"><i class="bi bi-twitter"></i> Twitter</p>
                </div>
              </div>
            </div>
            <div class="row gx-0 mb-2 justify-content-center align-items-center">
              <div class="d-flex justify-content-center fs-2">
                <i class="bi bi-person"></i> 980
                <span class="badge bg-light text-danger fs-6 px-0 py-0">
                                    <i class="bi bi-chevron-double-down"></i></i>5
                                </span>
              </div>
            </div>
            <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;"
                    data-bs-toggle="modal" data-bs-target="#statisticsModal">See More
            </button>
          </div>--}}

          {{--<div class="card m-1 border" style="max-width: 300px;">
            <div class="row gx-0 align-items-center">
              <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
              </div>
              <div class="col-md-6">
                <div class="card-body">
                  <h5 class="card-title fw-bold fs-4">nenieats</h5>
                  <p class="card-text"><i class="bi bi-facebook"></i> Facebook</p>
                </div>
              </div>
            </div>
            <div class="row gx-0 mb-2 justify-content-center align-items-center">
              <div class="d-flex justify-content-center fs-2">
                <i class="bi bi-person"></i> 1k
                <span class="badge bg-light text-success fs-6 px-0 py-0">
                                    <i class="bi bi-chevron-double-up"></i>10
                                </span>
              </div>
            </div>
            <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;"
                    data-bs-toggle="modal" data-bs-target="#statisticsModal">See More
            </button>
          </div>--}}

          {{--<div class="card m-1 border" style="max-width: 300px;">
            <div class="row gx-0 align-items-center">
              <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
              </div>
              <div class="col-md-6">
                <div class="card-body">
                  <h5 class="card-title fw-bold fs-4">nenicards</h5>
                  <p class="card-text"><i class="bi bi-twitter"></i> Twitter</p>
                </div>
              </div>
            </div>
            <div class="row gx-0 mb-2 justify-content-center align-items-center">
              <div class="d-flex justify-content-center fs-2">
                <i class="bi bi-person"></i> 130
                <span class="badge bg-light text-success fs-6 px-0 py-0">
                                    <i class="bi bi-chevron-double-up"></i></i>70
                                </span>
              </div>
            </div>
            <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;"
                    data-bs-toggle="modal" data-bs-target="#statisticsModal">See More
            </button>
          </div>--}}
        </div>
      </div>
    </div>
  </div>

  @include('partials.createProjectModal')
@endsection
