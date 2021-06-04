<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css", "overview.css"], ["min/min-text-bg.js"]); ?>

<?php draw_nav_bar(FALSE) ?>

<header class="page-header header container-md">
    <nav class="navbar navbar-expand-lg">
        <a class="navbar-brand text-dark" href="#">Sourdough Baking</a>
        <button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse"
                data-bs-target="#main-navigation-overview" aria-controls="main-navigation-overview"
                aria-expanded="false" aria-label="Toggle navigation">
            <i class="bi bi-caret-down project-nav-toggler"></i>
        </button>
        <div class="collapse navbar-collapse" id="main-navigation-overview">
            <ul class="navbar-nav d-lg-flex w-100 px-5 align-items-lg-end">
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
                    <a class="nav-link" href="project_settings.php"><span class="d-lg-none">Preferences</span><i
                                class="bi bi-gear me-2 d-none d-lg-inline-block"></i></a>
                </li>
                <li class="nav-item ms-lg-auto">
                    <a class="nav-link d-flex align-items-center" style="margin-right: 0.5em !important;"
                       data-bs-toggle="modal" data-bs-target="#tasks0Modal"><span class="mx-lg-2">Add Task</span> <i
                                class="bi bi-plus-circle fs-4 d-none d-lg-inline-block"></i></a>
                </li>
            </ul>
        </div>
    </nav>
</header>

<div class="container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start"
     id="overview">
    <div class="card m-2">
        <div class="card-header status-completed"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title">Get Ingredients</h5>

            <div class="d-flex flex-sm-column flex-row mb-2">
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
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-danger text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">must have</small></p>
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-info text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">cooking</small></p>
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-warning text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">must</small></p>
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-success text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">ingredients</small></p>
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">2<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks1Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2">
        <div class="card-header status-in-progress"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Feed the culture</h5>

            <div class="d-flex flex-sm-column flex-row mb-2">
                <div class="checklist my-auto">
                    <span class="text-secondary px-0 py-0">
                        <i class="bi bi-check2-circle"></i> <span class="d-none d-sm-inline-block">0/1</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-info text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">must do</small></p>
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-warning text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">routine</small></p>
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">1<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks2Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2">
        <div class="card-header status-waiting"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Bake</h5>

            <div class="d-flex flex-sm-column flex-row mb-2">
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

    <div class="card m-2">
        <div class="card-header status-not-started"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Prepare description</h5>

            <div class="d-flex flex-sm-column flex-row mb-2">
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

    <div class="card m-2">
        <div class="card-header status-waiting"></div>

        <div class="card-body d-flex flex-column">
            <h5 class="card-title ">Upload</h5>

            <div class="d-flex flex-sm-column flex-row mb-2">
                <div class="due-date my-auto mx-1 mx-sm-0">
                    <span class="text-muted">
                        <i class="bi bi-calendar-date"></i> <span class="d-none d-sm-inline-block">01/03/2021</span>
                    </span>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-info text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">instagram</small></p>
                <p class="d-inline-block m-0 py-1 px-3 px-sm-2 rounded bg-warning text-bg-check" type="button"><small
                            class="d-none d-sm-inline-block">twitter</small></p>
            </div>

            <div class="d-none d-sm-flex justify-content-between mt-2">
                <img class="rounded-circle " src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                <span class="text-end align-self-center ">6<i class="fas fa-comment-alt m-2"></i></span>
            </div>

            <a data-bs-toggle="modal" data-bs-target="#tasks5Modal" role="button" class="stretched-link p-0"></a>
        </div>
    </div>

    <div class="card m-2 border-3 border-secondary d-flex align-items-center justify-content-center"
         style="background-color: #efefef; border-style: dashed;">
        <i class="bi bi-plus-circle text-muted fs-2"></i>
        <a data-bs-toggle="modal" data-bs-target="#tasks0Modal" role="button" class="stretched-link p-0"></a>
    </div>
</div>

<?php draw_tasks_modal(0, "Title", "Description", [], [], "Not started"); ?>
<?php draw_tasks_modal(1, "Get ingredients", "None", [6 => "Go to the supermarket", 7 => "Go to farmer's market"], ["Flour", "Water"], "Completed"); ?>
<?php draw_tasks_modal(2, "Feed the culture", "Feed the culture", [], ["Drain culture"], "In progress"); ?>
<?php draw_tasks_modal(3, "Bake", "Feed the culture", [], ["Remove Portion", "Put starter in fridge"], "Waiting"); ?>
<?php draw_tasks_modal(4, "Prepare Description", "None", [], ["Ingredients", "Process", "Cute Quote"], "Not started"); ?>
<?php draw_tasks_modal(5, "Upload", "Prepare Description", [], [], "Waiting"); ?>
<?php draw_tasks_modal(6, "Go to the supermarket", "None", [], ["Fill tank", "Bring own bag"], "Completed"); ?>
<?php draw_tasks_modal(7, "Go to farmer's market", "None", [], ["Bring own bag"], "Completed"); ?>
<?php draw_footer(); ?>
