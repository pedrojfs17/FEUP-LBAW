<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css", "overview.css"], ["text-bg.js", "carousel.js"]); ?>

<?php draw_nav_bar(FALSE) ?>

<header class="page-header header container-md">
    <nav class="navbar navbar-expand-md">
        <a class="navbar-brand" href="#">Sourdough Baking</a>
        <button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#main-navigation-assignments" aria-controls="main-navigation-assignments" aria-expanded="false" aria-label="Toggle navigation">
            <i class="bi bi-caret-down project-nav-toggler"></i>
        </button>
        <div class="collapse navbar-collapse" id="main-navigation-assignments">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="project_overview.php">Overview</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="project_status.php">Status Board</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="project_assignments.php">Assignments</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="project_statistics.php">Statistics</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="project_settings.php"><i class="bi bi-gear me-2"></i></a>
                </li>
            </ul>
        </div>
    </nav>
</header>

<div class="row container-md mx-auto">
    <div class="col-lg-3">
        <div class="card mb-2">
            <div class="card-header bg-secondary text-center text-white ">
                Unassigned
            </div>
            <div class="card-body ">
                <div class="d-grid gap-2 ">
                    <button class="btn btn-light text-start " type="button ">Bake</button>
                </div>
            </div>
        </div>
    </div>
    <div class="container col">
        <div class="container-md text-center p-0 m-0">
            <div class="row mx-auto my-auto">
                <div id="cardCarousel" class="gx-0 carousel carousel-dark slide w-100 d-flex justify-content-center flex-column flex-lg-row" data-bs-interval="false">
                    <div class="d-flex justify-content-evenly my-3 d-lg-none">
                        <button class="w-auto border-0" data-bs-target="#cardCarousel" type="button" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Previous</span>
                        </button>
                        <button class="w-auto border-0" data-bs-target="#cardCarousel" type="button" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Next</span>
                        </button>
                    </div>    
                    <button class="w-auto border-0 d-none d-lg-block" data-bs-target="#cardCarousel" type="button" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Previous</span>
                    </button>
                    <div class="carousel-inner">
                        <div class="carousel-item active">
                            <div class="col-12 col-md-4">
                                <div class="card mb-2">
                                    <div class="card-header text-center text-bg-check" style="background-color: #68fbe7">
                                        Pedro Jorge
                                    </div>
                                    <div class="card-body ">
                                        <div class="d-grid gap-2 ">
                                            <button class="btn btn-light text-start " type="button ">Feed the culture</button>
                                            <button class="btn btn-light text-start " type="button ">Upload</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <div class="col-12 col-md-4">
                                <div class="card mb-2">
                                    <div class="card-header text-center text-bg-check" style="background-color: #eb4034">
                                        Antonio B.
                                    </div>
                                    <div class="card-body ">
                                        <div class="d-grid gap-2 ">
                                            <button class="btn btn-success text-start " type="button ">Get Ingredients</button>
                                            <button class="btn btn-light text-start " type="button ">Upload</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <div class="col-12 col-md-4">
                                <div class="card mb-2">
                                    <div class="card-header text-center text-bg-check" style="background-color: #f384f7">
                                        nenieats
                                    </div>
                                    <div class="card-body ">
                                        <div class="d-grid gap-2 ">
                                            <button class="btn btn-success text-start " type="button ">Get Ingredients</button>
                                            <button class="btn btn-light text-start " type="button ">Prepare Description</button>
                                            <button class="btn btn-light text-start " type="button ">Upload</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <div class="col-12 col-md-4">
                                <div class="card mb-2">
                                    <div class="card-header text-center text-bg-check" style="background-color: #d7fa2a">
                                        Gonçalo
                                    </div>
                                    <div class="card-body ">
                                        <div class="d-grid gap-2 ">
                                            <button class="btn btn-light text-start " type="button ">Upload</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <button class="w-auto border-0 d-none d-lg-block" data-bs-target="#cardCarousel" type="button" data-bs-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">Next</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<?php draw_footer(); ?>