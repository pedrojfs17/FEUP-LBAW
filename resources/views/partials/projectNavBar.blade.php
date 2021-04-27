<header class="page-header header container-md">
  <nav class="navbar navbar-expand-lg">
    <a class="navbar-brand text-dark" href="{{ route('project.overview', ['id' => $project->id]) }}">{{ $project->name }}</a>
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
          <a class="nav-link {{$page == 'statistics' ? 'active' : ''}}" href="{{ route('project.statistics', ['id' => $project->id]) }}">Statistics</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="{{ route('project.preferences', ['id' => $project->id]) }}"><span class="d-lg-none">Preferences</span><i
              class="bi bi-gear me-2 d-none d-lg-inline-block"></i></a>
        </li>
        <li class="nav-item ms-lg-auto">
          <a class="nav-link d-flex align-items-center" style="margin-right: 0.5em !important;"
             data-bs-toggle="modal" data-bs-target="#tasks0Modal"><span class="mx-lg-2">Add Task</span> <i
              class="bi bi-plus-circle fs-4 d-none d-lg-inline-block"></i></a>
        </li>
      </ul>
    </div>
  </nav>
</header>
