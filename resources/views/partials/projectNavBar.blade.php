<header class="page-header header container-md">
  <nav class="navbar navbar-expand-lg flex-lg-wrap flex-xl-nowrap">
    <a id="project-title" class="navbar-brand text-dark col-lg-12 col-xl-4" href="{{ route('project.overview', ['id' => $project->id]) }}">{{ $project->name }}</a>
    <button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse"
            data-bs-target="#main-navigation-overview" aria-controls="main-navigation-overview"
            aria-expanded="false" aria-label="Toggle navigation">
      <i class="bi bi-caret-down project-nav-toggler"></i>
    </button>
    <div class="collapse navbar-collapse col-lg-12 col-xl-8" id="main-navigation-overview">
      <ul class="navbar-nav d-lg-flex w-100 px-xl-5 align-items-lg-end">
        <li class="nav-item">
          <a class="nav-link {{$page == 'overview' ? 'active' : ''}}" href="{{ route('project.overview', ['id' => $project->id]) }}">Overview</a>
        </li>
        <li class="nav-item">
          <a class="nav-link {{$page == 'status' ? 'active' : ''}}" href="{{ route('project.status', ['id' => $project->id]) }}">Status Board</a>
        </li>
        <li class="nav-item">
          <a class="nav-link {{$page == 'assignments' ? 'active' : ''}}" href="{{ route('project.assignments', ['id' => $project->id]) }}">Assignments</a>
        </li>
        <li class="nav-item">
          <a class="nav-link {{$page == 'statistics' ? 'active' : ''}}" {{--href="{{ route('project.statistics', ['id' => $project->id]) }}"--}}>Statistics</a>
        </li>
        <li class="nav-item">
          <a class="nav-link {{$page == 'preferences' ? 'active' : ''}}" href="{{ route('project.preferences', ['id' => $project->id]) }}">Preferences</a>
        </li>
        @if ($page == 'overview')
          <hr>
          <li>
            <button class="btn btn-light mx-1 d-none d-lg-inline-block" type="button" id="button-filter-projects" data-bs-toggle="modal" data-bs-target="#taskFilterModal">
              <i class="text-muted bi bi-funnel-fill"></i>
            </button>
            <a class="nav-link d-lg-none" role="button" data-bs-toggle="modal" data-bs-target="#taskFilterModal">
              Filter
            </a>
          </li>
          @if ($role != 'Reader')
          <li class="nav-item ms-lg-auto dropdown">
            <a class="nav-link d-none d-lg-inline-block" id="createDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="margin-right: 0.5em !important;">
              <i class="bi bi-plus-circle fs-4"></i>
            </a>
            <a class="nav-link d-lg-none" role="button" data-bs-toggle="dropdown" aria-expanded="false">
              Create
            </a>
            <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="createDropdown">
              <li><a class="dropdown-item" data-bs-toggle="offcanvas" href="#createTask" aria-controls="createTask">Task</a></li>
              <li><a class="dropdown-item" data-bs-toggle="offcanvas" href="#createTag" aria-controls="createTag">Tag</a></li>
            </ul>
          </li>
          @endif
        @endif
      </ul>
    </div>
  </nav>
</header>

@if ($page == 'overview')
  @include('partials.projectCreateElements')
  @include('partials.taskFilter')
@endif
