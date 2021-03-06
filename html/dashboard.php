<?php
    include_once('templates/tpl_common.php');
?>

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

    <link rel="stylesheet" href="css/style.css">

    <!-- Bootstrap JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js" integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0" crossorigin="anonymous" defer></script>
    <script src="js/script.js" defer></script>
</head>

<body>
    <?php draw_nav_bar() ?>

    <div class="container">
        <ul class="nav nav-tabs mb-3 mt-sm-5" id="dashboardNav" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active fs-3" id="myprojects-tab" data-bs-toggle="tab" data-bs-target="#myprojects" type="button" role="tab" aria-controls="myprojects" aria-selected="true">Projects</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link fs-3" id="mystats-tab" data-bs-toggle="tab" data-bs-target="#mystats" type="button" role="tab" aria-controls="mystats" aria-selected="false">Statistics</button>
            </li>
        </ul>
        <div class="tab-content" id="dashboardContent">
            <div class="tab-pane fade show active" id="myprojects" role="tabpanel" aria-labelledby="myprojects-tab">
                <div class="row mb-3">
                    <div class="col-lg-8 col-md-8">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="Find Projects" aria-label="Find Projects" aria-describedby="button-search">
                            <button class="btn btn-outline-secondary" type="button" id="button-search"><i class="bi bi-search"></i></button>
                        </div>
                    </div>
                    <div class="d-flex col-lg-4 col-md-4 col-sm-12 mt-3 mt-md-0">
                        <a href="create_project.php" role="button" class="btn btn-danger flex-grow-1 flex-md-grow-0" style="background-color: #ea4c89;">+ New Project</a>
                    </div>
                </div>
                <div class="accordion" id="accordionProjects">
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingOne">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                Open
                                </button>
                        </h2>
                        <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne">
                            <div class="accordion-body">
                                <div role="button" class="card my-2">
                                    <div class="card-body">
                                        <h5 class="card-title"><a class="stretched-link text-decoration-none text-reset" href="project_overview.php">The Ultimate Apple Pie</a></h5>
                                        <div class="row align-items-center">
                                            <div class="col-lg-3 col-md-3 d-none d-md-block">
                                                <ul class="avatar-overlap">
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                </ul>
                                            </div>
                                            <div class="col-lg-3 col-md-3 text-muted">ETA: 2 weeks</div>
                                            <div class="col-lg-4 offset-lg-2 col-md-4 offset-md-2 text-end text-muted">Progress
                                                <div class="progress">
                                                    <div class="progress-bar bg-success" role="progressbar" style="width: 50%" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100">50%</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div role="button" class="card my-2">
                                    <div class="card-body">
                                        <h5 class="card-title"><a class="stretched-link text-decoration-none text-reset" href="project_overview.php">Sourdough Baking</a></h5>
                                        <div class="row align-items-center">
                                            <div class="col-lg-3 col-md-3">
                                                <ul class="avatar-overlap d-none d-md-block">
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                </ul>
                                            </div>
                                            <div class="col-lg-3 col-md-3 text-muted">ETA: 2 weeks</div>
                                            <div class="col-lg-4 offset-lg-2 col-md-4 offset-md-2 text-end text-muted">Progress
                                                <div class="progress">
                                                    <div class="progress-bar bg-success" role="progressbar" style="width: 25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100">25%</div>
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
                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                                Closed
                                </button>
                        </h2>
                        <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo">
                            <div class="accordion-body">
                                <div class="card my-2">
                                    <div class="card-body">
                                        <h5 class="card-title"><a class="stretched-link text-decoration-none text-reset" href="project_overview.php">Valentine 's day campaign</a></h5>
                                        <div class="row align-items-center">
                                            <div class="col-lg-3 col-md-3 d-none d-md-block">
                                                <ul class="avatar-overlap">
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                    <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                                </ul>
                                            </div>
                                            <div class="col-lg-3 col-md-3 text-muted">Completed 5 days ago</div>
                                            <div class="col-lg-4 offset-lg-2 col-md-4 offset-md-2 text-end text-muted">Progress
                                                <div class="progress">
                                                    <div class="progress-bar bg-success" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">Completed</div>
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

            <div class="tab-pane fade" id="mystats" role="tabpanel" aria-labelledby="mystats-tab">
                <div class="row mb-3">
                    <div class="col-lg-8 col-md-8">
                        <div class="input-group">
                            <input type="text" class="form-control" placeholder="Find Accounts" aria-label="Find Accounts" aria-describedby="button-search-acc">
                            <button class="btn btn-outline-secondary" type="button" id="button-search-acc"><i class="bi bi-search"></i></button>
                        </div>
                    </div>
                    <div class="d-flex col-lg-4 col-md-4 col-sm-12 mt-3 mt-md-0">
                        <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0" style="background-color: #ea4c89;">+ Connect Account</a>
                    </div>
                </div>
                <div class="d-flex flex-wrap align-content-start justify-content-center justify-content-md-between">
                    <div class="card m-1 border" style="max-width: 300px;">
                        <div class="row gx-0 align-items-center">
                            <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
                            </div>
                            <div class="col-md-6">
                                <div class="card-body">
                                    <h5 class="card-title fw-bold fs-4">nenieats</h5>
                                    <p class="card-text"><i class="bi bi-instagram"></i> Instagram</p>
                                </div>
                            </div>
                        </div>
                        <div class="row gx-0 mb-2 justify-content-center align-items-center">
                            <div class="d-flex justify-content-center fs-2">
                                <i class="bi bi-person"></i> 1.7k
                                <span class="badge bg-light text-success fs-6 px-0 py-0">
                                        <i class="bi bi-chevron-double-up"></i>23
                                    </span>
                            </div>
                        </div>
                        <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;">See More</button>
                    </div>

                    <div class="card m-1 border" style="max-width: 300px;">
                        <div class="row gx-0 align-items-center">
                            <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
                            </div>
                            <div class="col-md-6">
                                <div class="card-body">
                                    <h5 class="card-title fw-bold fs-4">nenieats</h5>
                                    <p class="card-text"><i class="bi bi-twitter"></i> Twitter</p>
                                </div>
                            </div>
                        </div>
                        <div class="row gx-0 mb-2 justify-content-center align-items-center">
                            <div class="d-flex justify-content-center fs-2">
                                <i class="bi bi-person"></i> 980
                                <span class="badge bg-light text-danger fs-6 px-0 py-0">
                                        <i class="bi bi-chevron-double-down"></i></i>5
                                    </span>
                            </div>
                        </div>
                        <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;">See More</button>
                    </div>

                    <div class="card m-1 border" style="max-width: 300px;">
                        <div class="row gx-0 align-items-center">
                            <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
                            </div>
                            <div class="col-md-6">
                                <div class="card-body">
                                    <h5 class="card-title fw-bold fs-4">nenieats</h5>
                                    <p class="card-text"><i class="bi bi-facebook"></i> Facebook</p>
                                </div>
                            </div>
                        </div>
                        <div class="row gx-0 mb-2 justify-content-center align-items-center">
                            <div class="d-flex justify-content-center fs-2">
                                <i class="bi bi-person"></i> 1k
                                <span class="badge bg-light text-success fs-6 px-0 py-0">
                                        <i class="bi bi-chevron-double-up"></i>10
                                    </span>
                            </div>
                        </div>
                        <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;">See More</button>
                    </div>

                    <div class="card m-1 border" style="max-width: 300px;">
                        <div class="row gx-0 align-items-center">
                            <div class="col-md-6 p-lg-4 p-md-2 px-5 pt-1">
                                <img src="images/avatar.png" alt="account avatar" class="img-fluid">
                            </div>
                            <div class="col-md-6">
                                <div class="card-body">
                                    <h5 class="card-title fw-bold fs-4">nenicards</h5>
                                    <p class="card-text"><i class="bi bi-twitter"></i> Twitter</p>
                                </div>
                            </div>
                        </div>
                        <div class="row gx-0 mb-2 justify-content-center align-items-center">
                            <div class="d-flex justify-content-center fs-2">
                                <i class="bi bi-person"></i> 130
                                <span class="badge bg-light text-success fs-6 px-0 py-0">
                                        <i class="bi bi-chevron-double-up"></i></i>70
                                    </span>
                            </div>
                        </div>
                        <button type="button" class="btn btn-light card-footer" style="background-color:#f5ebef;">See More</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Notifications</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row justify-content-center">
                        <div class="col-lg-12 col-md-12">
                            <div class="tab-content" id="dashboardContent">
                                <div class="tab-pane fade show active" id="myprojects" role="tabpanel" aria-labelledby="myprojects-tab">
                                    <div class="card">
                                        <div class="card-body">
                                            <p class="card-text">Jane Doe invited you to "The Ultimate Apple Pie"</p>
                                            <a href="#" class="stretched-link"></a>
                                        </div>
                                    </div>
                                    <div class="card">
                                        <div class="card-body">
                                            <p class="card-text">"Get Ingredients" has been finished. You can start working on "Feed the culture"</p>
                                            <a href="#" class="stretched-link"></a>
                                        </div>
                                    </div>
                                    <div class="card">
                                        <div class="card-body">
                                            <p class="card-text">John Doe entered "Sourdough Baking"</p>
                                            <a href="#" class="stretched-link"></a>
                                        </div>
                                    </div>
                                    <div class="card">
                                        <div class="card-body">
                                            <p class="card-text" data-bs-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample"><span>Your report has been dealt with<i class="pull-right icon-chevron-right"></i></span></p>
                                        </div>
                                        <div class="collapse" id="collapseExample">
                                            <div class="card card-body">
                                                <strong>We reviewed antbz's account and found that it does not violate our community guidelines</strong>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="tab-pane fade" id="mystats" role="tabpanel" aria-labelledby="mystats-tab">My Stats</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>

</html>