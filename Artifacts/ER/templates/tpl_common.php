<?php include_once('templates/tpl_modal.php'); ?>

<?php function draw_header($cssFiles, $jsFiles) { ?>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Oversee</title>

        <!-- Fav Icon -->
        <link rel="icon" href="images/oversee_blue.svg">

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl" crossorigin="anonymous">
        
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.0/font/bootstrap-icons.css">

        <!-- Fontawesome Icons -->
        <script src="https://kit.fontawesome.com/8d94371726.js" crossorigin="anonymous"></script>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">

        <!-- Bootstrap JavaScript -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js" integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0" crossorigin="anonymous" defer></script>

        <!-- Custom Fonts -->
        <link href="https://fonts.googleapis.com/css?family=Catamaran:100,200,300,400,500,600,700,800,900" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css?family=Lato:100,100i,300,300i,400,400i,700,700i,900,900i" rel="stylesheet">

        <!-- CSS Files -->
        <?php foreach($cssFiles as $cssFile) { ?>
            <link rel="stylesheet" href="css/<?= $cssFile ?>">
        <?php } ?>

        <!-- JS Files -->
        <?php foreach($jsFiles as $jsFile) { ?>
            <script src="js/<?= $jsFile ?>" defer></script>
        <?php } ?>
    </head>

    <body>
<?php } ?>


<?php function draw_landing_footer() { ?>
    <footer class="site-footer">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-sm-12 col-md-6">
                    <img class="d-inline-block align-top" src="images/oversee_blue_txt_only.svg" height="60" alt="">
                    <p class="text-justify mt-4">The social media focused project manager.<br>Developed as coursework for LBAW@FEUP 20/21. </p>
                </div>

                <div class="col-xs-6 col-md-3 ms-auto mb-2 mb-lg-0">
                    <a id="contact-us" class="btn btn-xl btn-outline-primary my-2 my-sm-0 text-decoration-none" href="contacts.php">Contact Us</a>
                </div>
            </div>
            <hr>
        </div>
        <div class="container me-auto">
            <div class="row">
                <div class="col-md-8 col-sm-6 col-xs-12">
                    <p class="copyright-text">Copyright &copy; 2021 All Rights Reserved by
                        <a href="#">lbaw2134</a>.
                    </p>
                </div>

                <div class="col-md-4 col-sm-6 col-xs-12">
                    <ul class="social-icons">
                        <li><a class="facebook" href="#"><i class="fa fa-facebook"></i></a></li>
                        <li><a class="twitter" href="#"><i class="fa fa-twitter"></i></a></li>
                        <li><a class="dribbble" href="#"><i class="fa fa-dribbble"></i></a></li>
                        <li><a class="linkedin" href="#"><i class="fa fa-linkedin"></i></a></li>
                    </ul>
                </div>
            </div>
        </div>
    </footer>

    <?php draw_footer(); ?>
    
<?php } ?>


<?php function draw_footer() { ?>
    </body>

    </html>
<?php } ?>


<?php function draw_landing_nav_bar() { ?>
    <nav id="navbar" class="navbar navbar-expand-lg navbar-dark navbar-custom fixed-top">
        <div class="container">
            <a class="navbar-brand" href="index.php">
                <img class="d-inline-block align-top img-fluid" src="images/oversee_blue_txt.svg" height="60" alt="">
            </a>
            <button id="navToggler" class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarResponsive">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0 fs-1">
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


<?php function draw_nav_bar($admin) { ?>
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

    <?php draw_notifications_modal(); ?>

<?php } ?>
