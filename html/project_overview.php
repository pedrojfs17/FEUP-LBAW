<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css", "overview.css"], []); ?>

<?php draw_nav_bar() ?>

<header class="page-header header container-md">
    <nav class="navbar navbar-expand-md">
        <a class="navbar-brand" href="#">Sourdough Baking</a>
        <button class="navbar-toggler navbar-dark" type="button" data-toggle="collapse" data-target="#main-navigation-overview">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="main-navigation-overview">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link active" href="project_overview.php">Overview</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="project_status.php">Status Board</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="project_assignments.php">Assignments</a>
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

<div class="container-md d-flex flex-wrap align-content-start justify-content-center justify-content-md-start">
    <div class="card m-2 " style="min-width: 300px;">
        <div class=" card-header bg-success text-white ">
            Completed
        </div>
        <div class="card-body d-flex flex-column">
            <h5 class="card-title">Get Ingredients</h5>
            <div class="d-grid gap-2 my-3">
                <button class="btn btn-light text-start " type="button" data-bs-toggle="modal" data-bs-target="#tasks1Modal">Flour</button>
                <button class="btn btn-light text-start " type="button" data-bs-toggle="modal" data-bs-target="#tasks1Modal">Water</button>
            </div>
            <div class="d-flex gap-2 my-3">
                <p class="d-inline-block py-1 px-2 rounded bg-danger text-white" type="button ">must have</p>
            </div>
            <div class="d-flex justify-content-between mt-auto">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">2<i class="fas fa-comment-alt m-2"></i></span>
            </div>
        </div>
    </div>

    <div class="card m-2 " style="min-width: 300px;">
        <div class="card-header bg-info text-white ">
            In progress
        </div>
        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Feed the culture</h5>
            <div class="d-grid gap-2 my-3">
                <button class="btn btn-light text-start " type="button " data-bs-toggle="modal" data-bs-target="#tasks2Modal">Drain culture</button>
            </div>
            <div class="d-flex gap-2 my-3">
                <p class="d-inline-block py-1 px-2 rounded bg-info " type="button ">must do</p>
                <p class="d-inline-block py-1 px-2 rounded bg-warning " type="button ">routine</p>
            </div>
            <span class="card-text"><i class="far fa-calendar-alt m-2"></i>28/02/2021</span>
            <div class="d-flex justify-content-between mt-auto">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">1<i class="fas fa-comment-alt m-2"></i></span>
            </div>
        </div>
    </div>

    <div class="card m-2 " style="min-width: 300px;">
        <div class="card-header bg-warning text-white ">
            Waiting
        </div>

        <div class="card-body d-flex flex-column ">
            <h5 class="card-title ">Bake</h5>
            <div class="d-grid gap-2 my-3">
                <button class="btn btn-light text-start " type="button " data-bs-toggle="modal" data-bs-target="#tasks3Modal">Remove portion</button>
                <button class="btn btn-light text-start " type="button " data-bs-toggle="modal" data-bs-target="#tasks3Modal">Put starter in fridge</button>
            </div>
            <div class="d-flex justify-content-between mt-auto">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">0<i class="fas fa-comment-alt m-2"></i></span>
            </div>
        </div>
    </div>

    <div class="card m-2 " style="min-width: 300px;">
        <div class="card-header bg-secondary text-white ">
            Not started
        </div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Prepare description</h5>
            <div class="d-grid gap-2 my-3">
                <button class="btn btn-light text-start " type="button " data-bs-toggle="modal" data-bs-target="#tasks4Modal">Ingredients</button>
                <button class="btn btn-light text-start " type="button " data-bs-toggle="modal" data-bs-target="#tasks4Modal">Process</button>
                <button class="btn btn-light text-start " type="button " data-bs-toggle="modal" data-bs-target="#tasks4Modal">Cute Quote</button>
            </div>
            <div class="d-flex justify-content-between mt-auto">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">5<i class="fas fa-comment-alt m-2"></i></span>
            </div>
        </div>
    </div>

    <div class="card m-2 " style="min-width: 300px;">
        <div class="card-header bg-warning text-white ">
            Waiting
        </div>
        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Upload</h5>
            <div class="d-flex gap-2 my-3">
                <p class="d-inline-block py-1 px-2 rounded bg-info ">instagram</p>
                <p class="d-inline-block py-1 px-2 rounded bg-warning">twitter</p>
            </div>
            <span class="card-text "><i class="far fa-calendar-alt m-2"></i>01/03/2021</span>
            <div class="d-flex justify-content-between mt-auto">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">6<i class="fas fa-comment-alt m-2"></i></span>
            </div>
        </div>
    </div>
</div>

<?php draw_tasks_modal(1, "Get ingredients", ["Flour", "Water"], "Completed");?>
<?php draw_tasks_modal(2, "Feed the culture", ["Drain culture"], "In progress");?>
<?php draw_tasks_modal(3, "Bake", ["Remove Portion", "Put starter in fridge"], "Waiting");?>
<?php draw_tasks_modal(4, "Prepare Description", ["Ingredients", "Process", "Cute Quote"], "Not started");?>
<?php draw_footer(); ?>
