<?php
    include_once('templates/tpl_common.php');
?>
        
<?php draw_header(["style.css"], []); ?>

<?php draw_nav_bar(FALSE) ?>

<div class="container">
    <div class="row my-4">
        <div class="input-group">
            <input type="text" class="form-control fs-4" placeholder="Search" aria-label="Search" aria-describedby="button-search">
            <button class="btn btn-outline-secondary" type="button" id="button-search"><i class="bi bi-search"></i></button>
        </div>
    </div>
    <div class="accordion" id="accordionSearch">
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingOne">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                Projects
                </button>
            </h2>
            <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne">
                <div class="accordion-body">
                    <div class="card my-2">
                        <div class="card-body">
                            <h5 class="card-title">Delicious and Vicious: The Spiciest Chilli</h5>
                            <div class="row align-items-center">
                                <div class="col-lg-3 col-md-3 d-none d-md-block">
                                    <ul class="avatar-overlap">
                                        <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                        <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                        <li class="avatar-overlap-item"><img class="rounded-circle" src="images/avatar.png" width="40px" height="40px" alt="avatar"></li>
                                    </ul>
                                </div>
                                <div class="col-lg-3 col-md-3 text-muted">Completed 3 months ago</div>
                                <div class="col-lg-4 offset-lg-2 col-md-4 offset-md-2 text-end text-muted">Progress
                                    <div class="progress">
                                        <div class="progress-bar bg-success" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">Completed</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingTwo">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="true" aria-controls="collapseTwo">
                Tasks
                </button>
            </h2>
            <div id="collapseTwo" class="accordion-collapse collapse show" aria-labelledby="headingTwo">
                <div class="accordion-body">
                    <div class="card my-2">
                        <div class="card-body">
                            <h5 class="card-title">Deliver pie samples to remote taste testers.</h5>
                            <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb">
                                <ol class="my-0 breadcrumb">
                                    <li class="breadcrumb-item"><a href="#">My Projects</a></li>
                                    <li class="breadcrumb-item"><a href="#">The Ultimate Apple Pie</a></li>
                                    <li class="breadcrumb-item"><a href="#">Research Recipe</a></li>
                                    <li class="breadcrumb-item active" aria-current="page">Task</li>
                                </ol>
                            </nav>
                        </div>
                    </div>
                    <div class="card my-2">
                        <div class="card-body">
                            <h5 class="card-title">Delete old account posts that do not fit new brand image.</h5>
                            <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb">
                                <ol class="my-0 breadcrumb">
                                    <li class="breadcrumb-item"><a href="#">My Projects</a></li>
                                    <li class="breadcrumb-item"><a href="#">2020 Re-brand</a></li>
                                    <li class="breadcrumb-item"><a href="#">Instagram Actions</a></li>
                                    <li class="breadcrumb-item active" aria-current="page">Checklist Item</li>
                                </ol>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="accordion-item">
            <h2 class="accordion-header" id="headingThree">
                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseThree" aria-expanded="true" aria-controls="collapseThree">
                Settings
                </button>
            </h2>
            <div id="collapseThree" class="accordion-collapse collapse show" aria-labelledby="headingThree">
                <div class="accordion-body">
                    <div class="card my-2">
                        <div class="card-body">
                            <h5 class="card-title">Delete account</h5>
                            <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb">
                                <ol class="my-0 breadcrumb">
                                    <li class="breadcrumb-item"><a href="#">Settings</a></li>
                                    <li class="breadcrumb-item active" aria-current="page">Account</li>
                                </ol>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php draw_footer(); ?>
