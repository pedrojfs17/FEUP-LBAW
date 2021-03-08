<?php
    include_once('templates/tpl_common.php');
    include_once('templates/tpl_modal.php');
?>

<?php draw_header(["style.css", "overview.css"], ["script.js"]); ?>

<?php draw_nav_bar(TRUE); ?>

<header class="page-header header container-md">
    <nav class="navbar navbar-expand-md">
        <a class="navbar-brand" href="#">Admin Dashboard</a>
        <button class="navbar-toggler navbar-dark" type="button" data-toggle="collapse" data-target="#main-navigation-overview">
        <span class="navbar-toggler-icon"></span>
    </button>
        <div class="collapse navbar-collapse" id="main-navigation-overview">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="admin_dashboard.php">Manage Users</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="admin_statistics.php">Statistics</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="admin_support.php">User Support</a>
                </li>
            </ul>
        </div>
    </nav>
</header>

<div class="container-md">
    <div class="d-flex justify-content-between mt-3 stats-dashboard ">
        <div class="d-flex flex-column flex-grow-1 stats-block">
            <div class="row align-items-center">
                <div class="col-lg-6 order-lg-1">
                    <h1>Total Users</h1>
                    <h6>+0,5% vs last week</h6>
                </div>
                <div class="col-lg-3 order-lg-2">
                    <h1 class="display-6">75%</h1>
                    <h5>women</h5>
                </div>
                <div class="col-lg-3 order-lg-3">
                    <h1 class="display-6">25%</h1>
                    <h5>men</h5>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-lg-6 order-lg-1">
                    <img class="img-fluid img-responsive shadow stats-block" src="https://www.datasciencemadesimple.com/wp-content/uploads/2017/08/Line-chart-in-python-1.png ">
                </div>
                <div class="col-lg-6 order-lg-2">
                    <h1>Top Countries</h1>
                    <div class="row align-items-center">
                        <div class="col-lg-3 order-lg-1">
                            <h4 class="p-5">Portugal<h4>
                        </div>
                        <div class="col-lg-9 order-lg-2">
                            <div class="progress">
                                <div class="progress-bar bg-success" role="progressbar" style="width: 53%" aria-valuenow="53" aria-valuemin="0" aria-valuemax="100">53%</div>
                            </div>
                        </div>
                    </div>
                    <div class="row align-items-center">
                        <div class="col-lg-3 order-lg-1">
                            <h4 class="p-5">USA<h4>
                        </div>
                        <div class="col-lg-9 order-lg-2">
                            <div class="progress">
                                <div class="progress-bar bg-success" role="progressbar" style="width: 12%" aria-valuenow="12" aria-valuemin="0" aria-valuemax="100">12%</div>
                            </div>
                        </div>
                    </div>
                    <div class="row align-items-center">
                        <div class="col-lg-3 order-lg-1">
                            <h4 class="p-5">Spain<h4>
                        </div>
                        <div class="col-lg-9 order-lg-2">
                            <div class="progress">
                                <div class="progress-bar bg-success" role="progressbar" style="width: 5.3%" aria-valuenow="5.3" aria-valuemin="0" aria-valuemax="100">5.3%</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
    </div>
        
</div>
<div class="container-md">
    <div class="d-flex justify-content-between mt-3 stats-dashboard ">
        <div class="d-flex flex-column flex-grow-1 stats-block">
            
            <div class="row align-items-center">
                <div class="col-lg-12 order-lg-1">
                    <h1>Total Projects</h1>
                    <h6>+1,2% vs last week</h6>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-lg-3 order-lg-3">
                    <h1 class="display-6">231%</h1>
                    <h5>Projects created</h5>
                </div>
                <div class="col-lg-3 order-lg-3">
                    <h1 class="display-6">16</h1>
                    <h5>Projects completed</h5>
                </div>
                <div class="col-lg-3 order-lg-3">
                    <h1 class="display-6">3.2</h1>
                    <h5>Avg Projects/User</h5>
                </div>
                <div class="col-lg-3 order-lg-3">
                    <h1 class="display-6">56%</h1>
                    <h5>Avg Project Progress</h5>
                </div>
            </div>
        </div>
        
    </div>
        
</div>

<?php draw_footer(); ?>