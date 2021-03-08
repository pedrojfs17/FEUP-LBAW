<?php
    include_once('templates/tpl_common.php');
?>

<!doctype html>
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
    <link rel="stylesheet" type="text/css" href="css/overview.css">

    <!-- Bootstrap JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js" integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0" crossorigin="anonymous" defer></script>
    <script src="js/script.js" defer></script>
</head>

<body>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js " integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin=" anonymous "></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.min.js " integrity="sha384-w1Q4orYjBQndcko6MimVbzY0tgp4pWB4lZ7lr30WKz0vr/aWKhXdBNmNb5D92v7s " crossorigin="anonymous "></script>

    <?php draw_nav_bar(FALSE) ?>

    <header class="page-header header container-md">
        <nav class="navbar navbar-expand-md">
            <a class="navbar-brand" href="#">Sourdough Baking</a>
            <button class="navbar-toggler navbar-dark" type="button" data-toggle="collapse" data-target="#main-navigation-assignments">
            <span class="navbar-toggler-icon"></span>
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
                </ul>
            </div>
        </nav>
    </header>

    <div class="row container-md mx-auto">
        <div class="col-md-3">
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
            <!--Carousel Wrapper-->
            <div id="multi-item-example" class="carousel slide carousel-multi-item" data-ride="carousel">
                <!--Slides-->
                <div class="carousel-inner" role="listbox">

                    <!--First slide-->
                    <div class="carousel-item active">

                        <div class="row">
                            <div class="col-md-4">
                                <div class="card mb-2">
                                    <div class="card-header bg-warning text-center text-white ">
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

                            <div class="col-md-4 clearfix d-none d-md-block">
                                <div class="card mb-2">
                                    <div class="card-header bg-warning text-center text-white ">
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

                            <div class="col-md-4 clearfix d-none d-md-block">
                                <div class="card mb-2">
                                    <div class="card-header bg-danger text-center text-white ">
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

                    </div>
                    <!--/.First slide-->

                    <!--Second slide-->
                    <div class="carousel-item">

                        <div class="row">
                            <div class="col-md-4">
                                <div class="card mb-2">
                                    <div class="card-header bg-info text-center text-white ">
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
                        <!--/.Second slide-->



                    </div>
                </div>
                <!--/.Slides-->
                <!--Controls-->
                <div class="controls-top">
                    <a class="btn-floating" href="#multi-item-example" data-slide="prev"><i class="fa fa-chevron-left"></i></a>
                    <a class="btn-floating" href="#multi-item-example" data-slide="next"><i class="fa fa-chevron-right"></i></a>
                </div>
                <!--/.Controls-->

            </div>
            <!--/.Carousel Wrapper-->

        </div>
    </div>
</body>

</html>