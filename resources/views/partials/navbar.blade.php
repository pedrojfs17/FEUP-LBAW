<nav class="navbar navbar-expand-sm navbar-light" style="background-color: #edf4f5;">
    <div class="container-fluid mx-sm-5">
        <a class="navbar-brand" href="dashboard.php">
            <img src="/images/oversee_blue.svg" width="30" height="30" class="d-inline-block align-top" alt="">Oversee
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link fs-5" href="search.php"><i class="bi bi-search"></i>
                        <p class="d-inline-block d-sm-none ps-2 mb-0">Search</p>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fs-5" href="#" data-bs-toggle="modal" data-bs-target="#notificationsModal">
                        <i class="bi bi-bell"></i>
                        <span class="badge rounded-pill badge-notify d-none d-sm-inline-block">3</span>
                        <p class="d-inline-block d-sm-none ps-2 mb-0">Notifications
                            <span class="badge rounded-pill bg-danger">3</span>
                        </p>
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link" href="" id="profileDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <img class="rounded-circle me-2" src="images/avatar.png" width="30px" height="30px" alt="avatar">
                        <?php if (!$admin) { ?>
                        Pedro Jorge
                        <?php } else { ?>
                        Admin
                        <?php } ?>
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="profileDropdown">
                        <?php if (!$admin) { ?>
                        <li><a class="dropdown-item" href="profile.php"><i class="bi bi-person me-2"></i>Profile</a></li>
                        <li><a class="dropdown-item" href="settings.php"><i class="bi bi-gear me-2"></i>Settings</a></li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <?php } ?>
                        <li><a class="dropdown-item" href="index.php"><i class="bi bi-box-arrow-left me-2"></i>Sign out</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
