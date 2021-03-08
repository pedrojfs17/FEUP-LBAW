<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css", "overview.css", "drag-and-drop.css"], ["drag-and-drop.js"]); ?>

<?php draw_nav_bar(FALSE) ?>

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
        <div class="col mb-3 task-group task-group-waiting">
            <div class="card">
                <div class="card-header text-center text-white ">
                    Waiting
                </div>
                <div class="card-body ">
                    <div class="d-grid gap-2 ">
                        <button id="task1" class="btn text-start draggable" type="button" draggable="true">Bake</button>
                        <button id="task2" class="btn text-start draggable" type="button" draggable="true">Upload</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="col mb-3 task-group task-group-not-started">
            <div class="card">
                <div class="card-header text-center text-white ">
                    Not started
                </div>
                <div class="card-body ">
                    <div class="d-grid gap-2 ">
                        <button id="task3" class="btn text-start draggable" type="button" draggable="true">Prepare description</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="col mb-3 task-group task-group-in-progress">
            <div class="card">
                <div class="card-header text-white text-center ">
                    In progress
                </div>
                <div class="card-body ">
                    <div class="d-grid gap-2 ">
                        <button id="task4" class="btn text-start draggable" type="button" draggable="true">Feed the culture</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="col mb-3 task-group task-group-completed">
            <div class="card">
                <div class="card-header text-white text-center ">
                    Completed
                </div>
                <div class="card-body ">
                    <div class="d-grid gap-2 ">
                        <button id="task5" class="btn text-start draggable" type="button" draggable="true">Get Ingredients</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php draw_footer(); ?>