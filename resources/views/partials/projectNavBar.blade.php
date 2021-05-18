<header class="page-header header container-md">
  <nav class="navbar navbar-expand-lg">
    <a id="project-title" class="navbar-brand text-dark" href="{{ route('project.overview', ['id' => $project->id]) }}">{{ $project->name }}</a>
    <button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse"
            data-bs-target="#main-navigation-overview" aria-controls="main-navigation-overview"
            aria-expanded="false" aria-label="Toggle navigation">
      <i class="bi bi-caret-down project-nav-toggler"></i>
    </button>
    <div class="collapse navbar-collapse" id="main-navigation-overview">
      <ul class="navbar-nav d-lg-flex w-100 px-5 align-items-lg-end">
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
        <li>
          <button class="btn btn-light mx-1" type="button" id="button-filter-projects" data-bs-toggle="modal" data-bs-target="#taskFilterModal"><i
              class="text-muted bi bi-funnel-fill"></i></button>
        </li>
        @if ($role != 'Reader')
        <li class="nav-item ms-lg-auto dropdown">
          <a class="nav-link" id="createDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false" style="margin-right: 0.5em !important;">
            <i class="bi bi-plus-circle fs-4 d-none d-lg-inline-block"></i>
          </a>
          <ul class="dropdown-menu dropdown-menu-dark" aria-labelledby="profileDropdown">
            <li><a class="dropdown-item" data-bs-toggle="offcanvas" href="#createTask" aria-controls="createTask">Task</a></li>
            <li><a class="dropdown-item" data-bs-toggle="offcanvas" href="#createTag" aria-controls="createTag">Tag</a></li>
          </ul>
        </li>
        @endif
      </ul>
    </div>
  </nav>
</header>

@include('partials.projectCreateElements')
