<?php
    include_once('templates/tpl_common.php');
?>

<!doctype html>
<html lang="en">


<head>
    <!-- Required meta tags -->
    <meta charset=" utf-8 ">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <script src="https://kit.fontawesome.com/8d94371726.js " crossorigin="anonymous "></script>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css " rel="stylesheet " integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl " crossorigin="anonymous ">

    <link rel="stylesheet " type="text/css " href="css/overview.css ">
    <title>Sourdough Baking</title>
</head>

<body>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js " integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin=" anonymous "></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.min.js " integrity="sha384-w1Q4orYjBQndcko6MimVbzY0tgp4pWB4lZ7lr30WKz0vr/aWKhXdBNmNb5D92v7s " crossorigin="anonymous "></script>

    <?php draw_nav_bar() ?>

    <header class="page-header header container-md">
        <nav class="navbar navbar-expand-md">
            <a class="navbar-brand" href="#">Sourdough Baking</a>
            <button class="navbar-toggler navbar-dark" type="button" data-toggle="collapse" data-target="#main-navigation-status">
            <span class="navbar-toggler-icon"></span>
        </button>
            <div class="collapse navbar-collapse" id="main-navigation-status">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="project_overview.php">Overview</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="project_status.php">Status Board</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="project_assignments.php">Assignments</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="project_statistics.php">Statistics</a>
                    </li>
                </ul>
            </div>
        </nav>
    </header>


    <div class="container-md pb-5">
        <div class="row">
            <div class="col mb-3">
                <div class="card">
                    <div class="card-header bg-warning text-center text-white ">
                        Waiting
                    </div>
                    <div class="card-body ">
                        <div class="d-grid gap-2 ">
                            <button class="btn btn-light text-start " type="button ">Bake</button>
                            <button class="btn btn-light text-start " type="button ">Upload</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col mb-3">
                <div class="card">
                    <div class="card-header bg-dark text-center text-white ">
                        Not started
                    </div>
                    <div class="card-body ">
                        <div class="d-grid gap-2 ">
                            <button class="btn btn-light text-start " type="button ">Prepare description</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col mb-3">
                <div class="card">
                    <div class="card-header bg-info text-white text-center ">
                        In progress
                    </div>
                    <div class="card-body ">
                        <div class="d-grid gap-2 ">
                            <button class="btn btn-light text-start " type="button ">Feed the culture</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col mb-3">
                <div class="card">
                    <div class="card-header bg-success text-white text-center ">
                        Completed
                    </div>
                    <div class="card-body ">
                        <div class="d-grid gap-2 ">
                            <button class="btn btn-light text-start " type="button ">Get Ingredients</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>

</html>