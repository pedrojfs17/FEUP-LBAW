<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["style.css", "overview.css"], []); ?>

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
                        <a class="nav-link" href="project_overview.php">Overview</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="project_status.php">Status Board</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="project_assignments.php">Assignments</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="project_statistics.php">Statistics</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="project_settings.php"><span class="d-lg-none">Preferences</span><i
                                    class="bi bi-gear me-2 d-none d-lg-inline-block"></i></a>
                    </li>
                    <li class="nav-item ms-lg-auto">
                        <a class="nav-link d-flex align-items-center" style="margin-right: 0.5em !important;"
                           href="#"><span class="mx-lg-2">Add Task</span> <i
                                    class="bi bi-plus-circle fs-4 d-none d-lg-inline-block"></i></a>
                    </li>
                </ul>
            </div>
        </nav>
    </header>

    <div class="container-md">
        <div class="d-flex justify-content-between mt-3 stats-dashboard ">
            <div class="d-flex flex-column flex-grow-1 stats-block">
                <h1>Twitter</h1>
                <ul class="list-group list-group-flush m-3 ">
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div><i class="far fa-heart m-1"></i> Likes</div>
                        <span class="badge bg-primary rounded-pill">320</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div><i class="fas fa-retweet m-1"></i> Retweets</div>
                        <span class="badge bg-primary rounded-pill">202</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div><i class="far fa-comment-alt m-1"></i> Comments</div>
                        <span class="badge bg-primary rounded-pill">34</span>
                    </li>
                </ul>
                <h3 class="my-3">Top tweet</h3>
                <div class=" d-flex flex-column">
                    <div class="card mx-3">
                        <div class="card-body ">
                            <h5 class="card-title ">Nenieats
                                <span class="text-secondary fs-6 fw-light">@nenieats</span>
                            </h5>
                            <p class="card-text ">New sourdough recipe! Check it out!</p>
                            <div class="d-flex">
                                <div class="mx-1"><i class=" far fa-heart m-1 "></i>128</div>
                                <div class="mx-1"><i class="fas fa-retweet m-1 "></i>53</div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <img class="img-fluid shadow stats-block"
                 src="https://www.datasciencemadesimple.com/wp-content/uploads/2017/08/Line-chart-in-python-1.png ">
        </div>
        <hr>
        <div class="d-flex justify-content-between mt-3 stats-dashboard">
            <div class="d-flex flex-column flex-grow-1 stats-block">
                <h1>Instagram</h1>
                <ul class="list-group list-group-flush m-3">
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div><i class="far fa-heart m-1"></i> Likes</div>
                        <span class="badge bg-primary rounded-pill">320</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div><i class="fas fa-retweet m-1"></i> Shares</div>
                        <span class="badge bg-primary rounded-pill">202</span>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div><i class="far fa-comment-alt m-1"></i> Comments</div>
                        <span class="badge bg-primary rounded-pill">34</span>
                    </li>
                </ul>
                <h3 class="my-3">Top posts</h3>
                <div class=" d-flex justify-content-between mx-3">
                    <div style="height:140px;width:140px;overflow:hidden;">
                        <img style="height:140px;"
                             src="https://assets.bonappetit.com/photos/597f6564e85ce178131a6475/master/w_1200,c_limit/0817-murray-mancini-dried-tomato-pie.jpg">
                    </div>

                    <div style="height:140px;width:140px;overflow:hidden;">
                        <img style="height:140px;"
                             src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-TO6bcocDTJ8RfvbWMSfyiqL-N_6lE83ETg&usqp=CAU">
                    </div>

                    <div style="height:140px;width:140px;overflow:hidden;">
                        <img style="height:140px;"
                             src="https://post.healthline.com/wp-content/uploads/2020/09/fried-eggs-plate-breakfast-protein-1200x628-facebook-1200x628.jpg">
                    </div>
                </div>
            </div>
            <img class="img-fluid shadow stats-block"
                 src="https://www.datasciencemadesimple.com/wp-content/uploads/2017/08/Line-chart-in-python-1.png ">
        </div>
    </div>

<?php draw_footer(); ?>