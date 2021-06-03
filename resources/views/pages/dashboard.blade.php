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
  @include('partials.projectFilter')

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
            <button class="btn btn-light mx-1" type="button" id="button-filter-projects" data-bs-toggle="modal" data-bs-target="#projectFilterModal"><i
                class="text-muted bi bi-funnel-fill"></i></button>
          </div>
          <div class="d-flex col-lg-4 col-md-4 col-sm-12 mt-3 mt-md-0">
            <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0"
                    data-bs-toggle="modal"
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
            <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0 disabled"
                    data-bs-toggle="modal" data-bs-target="#connectAccountModal">+ Connect Account
            </button>
          </div>
        </div>
        <div class="d-flex flex-wrap align-content-start justify-content-center justify-content-md-between">
          <h6 class="text-muted">Feature not available</h6>
        </div>
      </div>
    </div>
  </div>

  @include('partials.createProjectModal')
@endsection
