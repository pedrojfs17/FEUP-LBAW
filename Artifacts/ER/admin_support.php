<?php
include_once('templates/tpl_common.php');
include_once('templates/tpl_modal.php');
?>

<?php draw_header(["style.css", "overview.css", "one-page-wonder.css"], ["script.js"]); ?>

<?php draw_nav_bar(TRUE); ?>

    <header class="page-header header container-md">
        <nav class="navbar navbar-expand-md">
            <a class="navbar-brand" href="#">Admin Dashboard</a>
            <button class="navbar-toggler navbar-dark" type="button" data-toggle="collapse"
                    data-target="#main-navigation-overview">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="main-navigation-overview">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="admin_dashboard.php">Manage Users</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="admin_statistics.php">Statistics</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="admin_support.php">User Support</a>
                    </li>
                </ul>
            </div>
        </nav>
    </header>

    <div class="container">
        <div class="accordion" id="accordionSupport">
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingOne">
                    <button class="accordion-button" type="button" data-bs-toggle="collapse"
                            data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                        Unanswered
                    </button>
                </h2>
                <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne">
                    <div class="accordion-body">
                        <div class="card my-2">
                            <div class="card-body d-flex">
                                <p class="m-0 flex-grow-1">On 26-2-2021 <strong>nenieats</strong> said:<br><strong>Can't
                                        add members.</strong></p>
                                <div class="align-self-center mx-2" data-bs-toggle="collapse" href="#collapseExample"
                                     role="button" aria-expanded="false" aria-controls="collapseExample">
                                    <i class="fas fa-ellipsis-v"></i>
                                </div>
                            </div>


                            <div class="collapse" id="collapseExample">
                                <div class="card card-body">
                                    <div class="row align-items-center">
                                        <form>
                                            <div class="input-group mb-3">
                                                <textarea placeholder="Write your response" class="form-control"
                                                          id="textInput" rows="4" cols="50"></textarea>
                                            </div>
                                        </form>
                                        <a href="admin_dashboard.php" role="button" class="btn btn-primary">Send</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card my-2">
                            <div class="card-body d-flex">
                                <p class="m-0 flex-grow-1">On 26-2-2021 <strong>nenieats</strong> said:<br><strong>How
                                        to change tags?</strong></p>
                                <div class="align-self-center mx-2" data-bs-toggle="collapse" href="#collapseExample2"
                                     role="button" aria-expanded="false" aria-controls="collapseExample2">
                                    <i class="fas fa-ellipsis-v"></i>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample2">
                                <div class="card card-body">
                                    <div class="row align-items-center">
                                        <form>
                                            <div class="input-group mb-3">
                                                <textarea placeholder="Write your response" class="form-control"
                                                          id="textInput" rows="4" cols="50"></textarea>
                                            </div>
                                        </form>
                                        <a href="admin_dashboard.php" role="button" class="btn btn-primary">Send</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="accordion-item">
                <h2 class="accordion-header" id="headingTwo">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                            data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                        Answered
                    </button>
                </h2>
                <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo">
                    <div class="accordion-body">
                        <div class="card my-2">
                            <div class="card-body d-flex">
                                <p class="m-0 flex-grow-1">On 26-2-2021 <strong>nenieats</strong> said:<br><strong>Where
                                        can I change my profile picture?</strong></p>
                                <div class="align-self-center mx-2" data-bs-toggle="collapse" href="#collapseExample3"
                                     role="button" aria-expanded="false" aria-controls="collapseExample3">
                                    <i class="fas fa-ellipsis-v"></i>
                                </div>
                            </div>
                            <div class="collapse" id="collapseExample3">
                                <div class="card card-body py-2" style="background-color:#edf4f5;">
                                    <p class="my-0 flex-grow-1">Answered on 27-2-2021:<br><strong>You can edit it in
                                            your profile settings</strong></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

<?php draw_footer(); ?>