<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css", "overview.css"], ["text-bg.js"]); ?>

<?php draw_nav_bar(FALSE) ?>

<header class="page-header header container-md">
    <nav class="navbar navbar-expand-md">
        <a class="navbar-brand" href="#">Sourdough Baking</a>
        <button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#main-navigation-overview" aria-controls="main-navigation-overview" aria-expanded="false" aria-label="Toggle navigation">
            <i class="bi bi-caret-down project-nav-toggler"></i>
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

<div class="container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start">
    <div class="card m-2" style="width: 300px;">
        <div class="card-header status-completed"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title">Get Ingredients</h5>

            <div class="d-flex flex-sm-column flex-row my-2">
                <div class="checklist my-auto">
                    <span class="text-success px-0 py-0">
                        <i class="bi bi-check2-circle"></i> <span class="d-none d-sm-inline-block">Completed</span>
                    </span>
                </div>
                <div class="subtasks my-auto mx-1 mx-sm-0">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-list-check"></i> <span class="d-none d-sm-inline-block">1/2</span>
                    </span>
                </div>
                <div class="waiting-on my-auto mx-1 mx-sm-0">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-clock"></i> <span class="d-none d-sm-inline-block">0/1</span>
                    </span>
                </div>
                <div class="due-date my-auto mx-1 mx-sm-0">
                    <span class="text-muted">
                        <i class="bi bi-calendar-date"></i> <span class="d-none d-sm-inline-block">28/02/2021</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-danger text-bg-check" type="button ">must have</p>
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-info text-bg-check" type="button ">cooking</p>
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-warning text-bg-check" type="button ">must</p>
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-success text-bg-check" type="button ">ingredients</p>
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">2<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks1Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2" style="width: 300px;">
        <div class="card-header status-in-progress"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Feed the culture</h5>

            <div class="d-flex flex-sm-column flex-row my-2">
                <div class="checklist my-auto">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-check2-circle"></i> <span class="d-none d-sm-inline-block">0/1</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-info text-bg-check" type="button">must do</p>
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-warning text-bg-check" type="button">routine</p>
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">1<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks2Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2" style="width: 300px;">
        <div class="card-header status-waiting"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Bake</h5>

            <div class="d-flex flex-sm-column flex-row my-2">
                <div class="checklist my-auto">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-check2-circle"></i> <span class="d-none d-sm-inline-block">1/2</span>
                    </span>
                </div>
                <div class="subtasks my-auto mx-1 mx-sm-0">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-list-check"></i> <span class="d-none d-sm-inline-block">0/1</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">0<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks3Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2" style="width: 300px;">
        <div class="card-header status-not-started"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Prepare description</h5>

            <div class="d-flex flex-sm-column flex-row my-2">
                <div class="checklist my-auto">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-check2-circle"></i> <span class="d-none d-sm-inline-block">2/3</span>
                    </span>
                </div>
                <div class="subtasks my-auto mx-1 mx-sm-0">
                    <span class="text-success px-0 py-0">
                        <i class="bi bi-list-check"></i> <span class="d-none d-sm-inline-block">Completed</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">5<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks4Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2" style="width: 300px;">
        <div class="card-header status-waiting"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Upload</h5>

            <div class="d-flex flex-sm-column flex-row my-2">
                <div class="due-date my-auto mx-1 mx-sm-0">
                    <span class="text-muted">
                        <i class="bi bi-calendar-date"></i> <span class="d-none d-sm-inline-block">01/03/2021</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-info text-bg-check" type="button ">instagram</p>
                <p class="d-inline-block m-0 py-1 px-2 rounded bg-warning text-bg-check" type="button ">twitter</p>
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">6<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks5Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>
</div>

<?php draw_tasks_modal(1, "Get ingredients", ["Flour", "Water"], "Completed");?>
<?php draw_tasks_modal(2, "Feed the culture", ["Drain culture"], "In progress");?>
<?php draw_tasks_modal(3, "Bake", ["Remove Portion", "Put starter in fridge"], "Waiting");?>
<?php draw_tasks_modal(4, "Prepare Description", ["Ingredients", "Process", "Cute Quote"], "Not started");?>
<?php draw_tasks_modal(5, "Upload", [], "Waiting");?>
<?php draw_footer(); ?>
