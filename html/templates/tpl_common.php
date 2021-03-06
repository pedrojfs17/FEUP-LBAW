<?php function draw_header() { ?>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Oversee</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl" crossorigin="anonymous">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.0/font/bootstrap-icons.css">

        <!-- Bootstrap JavaScript -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js" integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0" crossorigin="anonymous" defer></script>
    </head>
<?php } ?>

<?php function draw_landing_nav_bar() { ?>
    <nav id="navbar" class="navbar navbar-expand-lg navbar-dark navbar-custom fixed-top">
        <div class="container">
            <a class="navbar-brand" href="#">
                <img class="d-inline-block align-top img-fluid" src="images/oversee_blue_txt.svg" height="60" alt="">
            </a>
            <button id="navToggler" class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarResponsive">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0 fs-1">
                    <li class="nav-item">
                        <a class="nav-link" href="index.php">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="contacts.php">Contacts</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sign_in.php">Sign In</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="sign_up.php">Sign Up</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
<?php } ?>

<?php function draw_nav_bar() { ?>
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
                        <a class="nav-link fs-5" href="#" data-bs-toggle="modal" data-bs-target="#exampleModal">
                            <i class="bi bi-bell"></i>
                            <span class="badge rounded-pill badge-notify d-none d-sm-inline-block">3</span>
                            <p class="d-inline-block d-sm-none ps-2 mb-0">Notifications
                                <span class="badge rounded-pill bg-danger">3</span>
                            </p>
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link" href="" id="profileDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <img class="rounded-circle me-2" src="images/avatar.png" width="30px" height="30px" alt="avatar"> Pedro Jorge
                        </a>
                        <ul class="dropdown-menu" aria-labelledby="profileDropdown">
                            <li><a class="dropdown-item" href="profile.php"><i class="bi bi-person me-2"></i>Profile</a></li>
                            <li><a class="dropdown-item" href="settings.php"><i class="bi bi-gear me-2"></i>Settings</a></li>
                            <li>
                                <hr class="dropdown-divider">
                            </li>
                            <li><a class="dropdown-item" href="index.php"><i class="bi bi-box-arrow-left me-2"></i>Sign out</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
<?php } ?>
