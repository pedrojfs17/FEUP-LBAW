<?php
include_once('templates/tpl_common.php');
include_once('templates/tpl_modal.php');
?>

<?php draw_header(["style.css", "overview.css"], ["script.js"]); ?>

<?php draw_nav_bar(TRUE); ?>

    <header class="page-header header container-md">
        <nav class="navbar navbar-expand-md">
            <a class="navbar-brand" href="#">Admin Dashboard</a>
            <button class="navbar-toggler navbar-dark" type="button" data-toggle="collapse"
                    data-target="#main-navigation-overview">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="main-navigation-overview">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="admin_dashboard.php">Manage Users</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="admin_statistics.php">Statistics</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="admin_support.php">User Support</a>
                    </li>
                </ul>
            </div>
        </nav>
    </header>

    <div class="container">
        <div class="accordion" id="accordionAdmin">
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingOne">
                    <button class="accordion-button" type="button" data-bs-toggle="collapse"
                            data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                        Reported Users
                    </button>
                </h2>
                <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne">
                    <div class="accordion-body">
                        <div class="card my-2">
                            <div class="card-body p-2">
                                <div class="d-flex">
                                    <div class="d-none d-sm-block">
                                        <img class="img-fluid rounded-circle" src="images/ps.jpg" width="50" alt="">
                                    </div>
                                    <div class="my-auto mx-3 flex-grow-1">
                                        <h5 class="my-0">Pedro Seixas</h5>
                                        <p class="my-0">up201806227@fe.up.pt</p>
                                    </div>
                                    <div class="align-self-center mx-2" data-bs-toggle="collapse"
                                         href="#collapseExample" role="button" aria-expanded="false"
                                         aria-controls="collapseExample">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample">
                                <div class="card card-body">
                                    <p>On 26-2-2021 <strong>nenieats</strong> said:<br>Unfaithful user, tiro nele.</p>
                                    <div class="row align-items-center">
                                        <div class="col-lg-2 col-md-1">
                                            <a href="admin_dashboard.php" role="button" class="btn btn-danger">Remove
                                                User</a>
                                        </div>
                                        <div class="col-lg-1 col-md-1">
                                            <a href="admin_dashboard.php" role="button"
                                               class="btn btn-secondary">Ignore</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card my-2">
                            <div class="card-body p-2">
                                <div class="d-flex">
                                    <div class="d-none d-sm-block">
                                        <img class="img-fluid rounded-circle" src="images/ga.jpg" width="50" alt="">
                                    </div>
                                    <div class="my-auto mx-3 flex-grow-1">
                                        <h5 class="my-0">Gon??alo Alves</h5>
                                        <p class="my-0">up201806451@fe.up.pt</p>
                                    </div>
                                    <div class="align-self-center mx-2" data-bs-toggle="collapse"
                                         href="#collapseExample2" role="button" aria-expanded="false"
                                         aria-controls="collapseExample2">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample2">
                                <div class="card card-body">
                                    <p>On 26-6-2021 <strong>nenieats</strong> said:<br>Made mean comment, don't like
                                        him.</p>
                                    <div class="row align-items-center">
                                        <div class="col-lg-2 col-md-1">
                                            <a href="admin_dashboard.php" role="button" class="btn btn-danger">Remove
                                                User</a>
                                        </div>
                                        <div class="col-lg-1 col-md-1">
                                            <a href="admin_dashboard.php" role="button"
                                               class="btn btn-secondary">Ignore</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingTwo">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                            data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                        All Users
                    </button>
                </h2>
                <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo">
                    <div class="accordion-body">
                        <div class="card my-2">
                            <div class="card-body p-2">
                                <div class="d-flex">
                                    <div class="d-none d-sm-block">
                                        <img class="img-fluid rounded-circle" src="images/ab.jpg" width="50" alt="">
                                    </div>
                                    <div class="my-auto mx-3 flex-grow-1">
                                        <h5 class="my-0">Ant??nio Bezerra</h5>
                                        <p class="my-0">up201806854@fe.up.pt</p>
                                    </div>
                                    <div class="align-self-center mx-2" data-bs-toggle="collapse"
                                         href="#collapseExample3" role="button" aria-expanded="false"
                                         aria-controls="collapseExample3">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample3">
                                <div class="card card-body">
                                    <div class="row align-items-center">
                                        <div class="col-lg-2 col-md-1">
                                            <a href="admin_dashboard.php" role="button" class="btn btn-danger">Remove
                                                User</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card my-2">
                            <div class="card-body p-2">
                                <div class="d-flex">
                                    <div class="d-none d-sm-block">
                                        <img class="img-fluid rounded-circle" src="images/ga.jpg" width="50" alt="">
                                    </div>
                                    <div class="my-auto mx-3 flex-grow-1">
                                        <h5 class="my-0">Gon??alo Alves</h5>
                                        <p class="my-0">up201806451@fe.up.pt</p>
                                    </div>
                                    <div class="align-self-center mx-2" data-bs-toggle="collapse"
                                         href="#collapseExample4" role="button" aria-expanded="false"
                                         aria-controls="collapseExample4">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample4">
                                <div class="card card-body">
                                    <div class="row align-items-center">
                                        <div class="col-lg-2 col-md-1">
                                            <a href="admin_dashboard.php" role="button" class="btn btn-danger">Remove
                                                User</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card my-2">
                            <div class="card-body p-2">
                                <div class="d-flex">
                                    <div class="d-none d-sm-block">
                                        <img class="img-fluid rounded-circle" src="images/is.jpg" width="50" alt="">
                                    </div>
                                    <div class="my-auto mx-3 flex-grow-1">
                                        <h5 class="my-0">In??s Silva</h5>
                                        <p class="my-0">up201806385@fe.up.pt</p>
                                    </div>
                                    <div class="align-self-center mx-2" data-bs-toggle="collapse"
                                         href="#collapseExample5" role="button" aria-expanded="false"
                                         aria-controls="collapseExample5">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample5">
                                <div class="card card-body">
                                    <div class="row align-items-center">
                                        <div class="col-lg-2 col-md-1">
                                            <a href="admin_dashboard.php" role="button" class="btn btn-danger">Remove
                                                User</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card my-2">
                            <div class="card-body p-2">
                                <div class="d-flex">
                                    <div class="d-none d-sm-block">
                                        <img class="img-fluid rounded-circle" src="images/ps.jpg" width="50" alt="">
                                    </div>
                                    <div class="my-auto mx-3 flex-grow-1">
                                        <h5 class="my-0">Pedro Seixas</h5>
                                        <p class="my-0">up201806227@fe.up.pt</p>
                                    </div>
                                    <div class="align-self-center mx-2" data-bs-toggle="collapse"
                                         href="#collapseExample6" role="button" aria-expanded="false"
                                         aria-controls="collapseExample6">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample6">
                                <div class="card card-body">
                                    <div class="row align-items-center">
                                        <div class="col-lg-2 col-md-1">
                                            <a href="admin_dashboard.php" role="button" class="btn btn-danger">Remove
                                                User</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

<?php draw_footer(); ?>