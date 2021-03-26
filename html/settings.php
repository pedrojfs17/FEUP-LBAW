<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css"], ["settings.js"]); ?>

<?php draw_nav_bar(FALSE) ?>

    <div class="container">
        <div class="row align-items-center mt-5">
            <h1><a class="fs-4 me-4" href="dashboard.php"><i class="bi bi-chevron-left"></i></a>Settings</h1>
        </div>

        <hr>

        <div class="row align-items-center mt-4 px-sm-5 px-1">
            <h4>Notifications</h4>
            <hr>
        </div>

        <div class="row justify-content-center align-items-begin px-sm-5 px-1">
            <div class="row mt-2 form-switch ps-0">
                <label class="form-check-label" for="allowNotifs">Allow Notifications</label>
                <input class="form-check-input" type="checkbox" id="allowNotifs">
            </div>
            <div id="notificationSettings" class="mt-3">
                <div class="row mb-3 form-switch mx-0">
                    <label class="form-check-label" for="invitesNotifs">Project Invites</label>
                    <input class="form-check-input" type="checkbox" id="invitesNotifs">
                </div>
                <div class="row mb-3 form-switch mx-0">
                    <label class="form-check-label" for="memberNotifs">New Project Members</label>
                    <input class="form-check-input" type="checkbox" id="memberNotifs">
                </div>
                <div class="row mb-3 form-switch mx-0">
                    <label class="form-check-label" for="tasksNotifs">Assigned Tasks</label>
                    <input class="form-check-input" type="checkbox" id="tasksNotifs">
                </div>
                <div class="row mb-3 form-switch mx-0">
                    <label class="form-check-label" for="waitingNotifs">Tasks leaving "Waiting"</label>
                    <input class="form-check-input" type="checkbox" id="waitingNotifs">
                </div>
                <div class="row mb-3 form-switch mx-0">
                    <label class="form-check-label" for="reportsNotifs">Reports</label>
                    <input class="form-check-input" type="checkbox" id="reportsNotifs">
                </div>
            </div>
        </div>

        <div class="row align-items-center mt-4 px-sm-5 px-1">
            <h4>Projects</h4>
            <hr>
        </div>

        <div class="row justify-content-center align-items-begin px-sm-5 px-1">
            <div class="row mt-2 form-switch ps-0">
                <label class="form-check-label" for="hideTasks">Hide Completed Tasks</label>
                <input class="form-check-input" type="checkbox" id="hideTasks">
            </div>
            <div class="row mt-3 form-switch ps-0">
                <label class="form-check-label" for="simpleTasks">Simplified Tasks</label>
                <input class="form-check-input" type="checkbox" id="simpleTasks">
            </div>
            <div class="row mt-2 form-switch ps-0 position-relative align-items-center">
                <label class="form-label mt-2" for="colorInput">Color</label>
                <input type="color" class="form-control form-control-color choose-color position-absolute top-0 end-0"
                       id="colorInput" value="#68fbe7" title="Choose your color">
            </div>

        </div>

        <div class="row align-items-center mt-4 px-sm-5 px-1">
            <h4>Account</h4>
            <hr>
        </div>

        <div class="row justify-content-center align-items-begin px-sm-5 px-1">
            <div class="d-grid gap-2">
                <p class="text-muted mb-2">Once you delete your account, there is no coming back...</p>
                <button class="btn btn-danger" type="button">Delete Account</button>
            </div>
        </div>
    </div>

<?php draw_footer(); ?>