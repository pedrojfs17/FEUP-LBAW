<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css"], ["min/min-settings.js"]); ?>

<?php draw_nav_bar(FALSE) ?>

    <div class="container">
        <div class="row align-items-center mt-5">
            <h1><a class="fs-4 me-4" href="project_overview.php"><i class="bi bi-chevron-left"></i></a>Project Settings
            </h1>
        </div>

        <hr>

        <div class="row align-items-center mt-5 px-5">
            <h4>Basic info</h4>
            <hr>
        </div>

        <div class="row justify-content-center align-items-begin px-5">
            <label for="title" class="form-label">Title
                <input id="title" class="form-control" type="text" placeholder="Sourdough Baking">
            </label>
            <label for="description" class="form-label">Description
                <input id="description" class="form-control" type="text"
                       placeholder="In a nutshell, sourdough is slow-fermented bread. It’s unique because it does not require commercial yeast in order to rise.">
            </label>
            <label for="description" class="form-label">Deadline
                <input id="description" class="form-control" type="date">
            </label>
        </div>
        <div class="row align-items-center mt-5 px-5">
            <h4>Manage members</h4>
            <hr>
        </div>

        <div class="card mx-5 my-1">
            <div class="card-body">
                <img class="rounded-circle d-inline-block mx-2" src="images/avatar.png" width="40px" height="40px"
                     alt="avatar">
                <h5 class="card-title d-inline-block">Pedro Jorge</h5>
                <button class="btn btn-danger float-end" type="button">Remove</button>
            </div>
        </div>
        <div class="card mx-5 my-1">
            <div class="card-body">
                <img class="rounded-circle d-inline-block mx-2" src="images/avatar.png" width="40px" height="40px"
                     alt="avatar">
                <h5 class="card-title d-inline-block">António Bezerra</h5>
                <button class="btn btn-danger float-end" type="button">Remove</button>
            </div>
        </div>

        <div class="row justify-content-center align-items-begin px-5 my-5">
            <div class="d-grid gap-2">
                <p class="text-muted mb-2">Once you delete this project, there is no coming back...</p>
                <button class="btn btn-danger" type="button">Delete Project</button>
            </div>
        </div>
    </div>

<?php draw_footer(); ?>
