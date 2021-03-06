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

    <!-- Multi Step Form -->
    <link rel="stylesheet" href="css/ms-form.css">
    <script src="js/ms-form.js" defer></script>
</head>

<body>
    <?php draw_nav_bar() ?>

    <div class="container">
        <div class="row fs-2 my-4 mx-2">New Project</div>
        <div class="row">
            <form id="msform">
                <div class="col-10 offset-1 mb-5">
                    <div class="position-relative m-4" id="progressbar">
                        <div class="progress" style="height: 2px;">
                            <div class="progress-bar" role="progressbar" style="width: 0%; background-color: #00AFB9;" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <button type="button" class="position-absolute top-0 start-0 translate-middle btn btn-sm rounded-pill active" style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-pencil fs-3"></i></button>
                        <button type="button" class="position-absolute top-0 start-50 translate-middle btn btn-sm rounded-pill" style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-gear fs-3"></i></button>
                        <button type="button" class="position-absolute top-0 start-100 translate-middle btn btn-sm rounded-pill" style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-person-plus fs-3"></i></button>
                    </div>
                </div>

                <hr>

                <fieldset>
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <legend class="fs-3" style="width: auto;">Basic Information</legend>
                        <h5 class="steps">Step 1 - 3</h5>
                    </div>
                    <div class="mb-3">
                        <label for="projectNameInput" class="form-label">Name</label>
                        <input type="text" class="form-control" id="projectNameInput" placeholder="Add Project Title">
                    </div>
                    <div class="mb-3">
                        <label for="projectDescriptionInput" class="form-label">Description</label>
                        <textarea class="form-control" id="projectDescriptionInput" rows="3" placeholder="Describe your project"></textarea>
                    </div>
                    <button type="button" class="next btn btn-lg btn-primary float-end">Next</button>
                    <a href="dashboard.php" role="button" class="btn btn-lg btn-secondary float-end mx-3">Cancel</a>
                </fieldset>

                <fieldset>
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <legend class="fs-3" style="width: auto;">Setup</legend>
                        <h5 class="steps">Step 2 - 3</h5>
                    </div>
                    <div class="mb-3" style="cursor: pointer;">
                        <div class="fs-5 px-3"> + End Date</div>
                    </div>
                    <div class="mb-3" style="cursor: pointer;">
                        <div class="fs-5 px-3"> + Connect Instagram</div>
                    </div>
                    <div class="mb-3" style="cursor: pointer;">
                        <div class="fs-5 px-3"> + Connect Twitter</div>
                    </div>
                    <button type="button" class="next btn btn-lg btn-primary float-end">Next</button>
                    <button type="button" class="previous btn btn-lg btn-secondary float-end mx-3">Previous</button>
                </fieldset>

                <fieldset>
                    <div class="d-flex justify-content-between align-items-center my-3">
                        <legend class="fs-3" style="width: auto;">Add Members</legend>
                        <h5 class="steps">Step 3 - 3</h5>
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" class="form-control" placeholder="Username or Email" aria-label="Find Members" aria-describedby="button-search">
                        <button class="btn btn-outline-secondary" type="button" id="button-search"><i class="bi bi-search"></i></button>
                    </div>
                    <button type="button" class="btn btn-lg btn-primary float-end">Submit</button>
                    <button type="button" class="previous btn btn-lg btn-secondary float-end mx-3">Previous</button>
                </fieldset>
            </form>
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