<header class="page-header header container-md">
  <nav class="navbar navbar-expand-lg">
    <a class="navbar-brand text-dark" href="{{ route('admin.users') }}">Administration</a>
    <button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse"
            data-bs-target="#main-navigation-overview" aria-controls="main-navigation-overview"
            aria-expanded="false" aria-label="Toggle navigation">
      <i class="bi bi-caret-down project-nav-toggler"></i>
    </button>
    <div class="collapse navbar-collapse" id="main-navigation-overview">
      <ul class="navbar-nav d-lg-flex w-100 px-5 align-items-lg-end">
        <li class="nav-item">
          <a class="nav-link {{$page == 'users' ? 'active' : ''}}" href="{{ route('admin.users') }}">Overview</a>
        </li>
        <li class="nav-item">
          <a class="nav-link {{$page == 'statistics' ? 'active' : ''}}" {{--href="{{ route('admin.statistics') }}"--}}>Statistics</a>
        </li>
        <li class="nav-item">
          <a class="nav-link {{$page == 'support' ? 'active' : ''}}" {{--href="{{ route('admin.support') }}"--}}>User Support</a>
        </li>
      </ul>
    </div>
  </nav>
</header>
