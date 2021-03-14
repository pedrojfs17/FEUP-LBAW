<?php function draw_create_project_modal()
{ ?>
    <div class="modal fade" id="createProjectModal" tabindex="-1" aria-labelledby="createProjectModalLabel" style="display: none;" aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title h4" id="createProjectModalLabel">New Project</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="container">
                        <div class="row">
                            <form id="msform">
                                <div class="col-10 offset-1 mb-5">
                                    <div class="position-relative m-4" id="progressbar">
                                        <div class="progress" style="height: 2px;">
                                            <div id="ms-form-progress-bar" class="progress-bar" role="progressbar" style="width: 0%; background-color: #00AFB9;" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100"></div>
                                        </div>
                                        <button type="button" class="position-absolute top-0 start-0 translate-middle btn btn-sm rounded-pill active" style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-pencil fs-3"></i></button>
                                        <button type="button" class="position-absolute top-0 start-50 translate-middle btn btn-sm rounded-pill" style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-gear fs-3"></i></button>
                                        <button type="button" class="position-absolute top-0 start-100 translate-middle btn btn-sm rounded-pill" style="width: 3rem; height:3rem; background-color: white;"><i class="bi bi-person-plus fs-3"></i></button>
                                    </div>
                                </div>

                                <hr>

                                <fieldset>
                                    <div class="d-flex justify-content-between align-items-center my-3">
                                        <legend class="fs-3" style="width: auto;">Basic Information</legend>
                                        <h5 class="steps">Step 1 - 3</h5>
                                    </div>
                                    <div class="mb-3">
                                        <label for="projectNameInput" class="form-label">Name <span class="text-muted">*</span></label>
                                        <input type="text" class="form-control" id="projectNameInput" placeholder="Add Project Title">
                                    </div>
                                    <div class="mb-3">
                                        <label for="projectDescriptionInput" class="form-label">Description</label>
                                        <textarea class="form-control" id="projectDescriptionInput" rows="3" placeholder="Describe your project"></textarea>
                                    </div>
                                    <button type="button" class="next btn btn-lg btn-primary float-end">Next</button>
                                    <button type="button" class="btn btn-lg btn-secondary float-end mx-3" data-bs-dismiss="modal">Cancel</a>
                                </fieldset>

                                <fieldset>
                                    <div class="d-flex justify-content-between align-items-center my-3">
                                        <legend class="fs-3" style="width: auto;">Setup</legend>
                                        <h5 class="steps">Step 2 - 3</h5>
                                    </div>
                                    <div class="mb-3" style="cursor: pointer;">
                                        <div class="fs-5 px-3"> + End Date</div>
                                    </div>
                                    <div class="mb-3" style="cursor: pointer;">
                                        <div class="fs-5 px-3"> + Connect Instagram</div>
                                    </div>
                                    <div class="mb-3" style="cursor: pointer;">
                                        <div class="fs-5 px-3"> + Connect Twitter</div>
                                    </div>
                                    <button type="button" class="next btn btn-lg btn-primary float-end">Next</button>
                                    <button type="button" class="previous btn btn-lg btn-secondary float-end mx-3">Previous</button>
                                </fieldset>

                                <fieldset>
                                    <div class="d-flex justify-content-between align-items-center my-3">
                                        <legend class="fs-3" style="width: auto;">Add Members</legend>
                                        <h5 class="steps">Step 3 - 3</h5>
                                    </div>
                                    <div class="input-group mb-3">
                                        <input type="text" class="form-control" placeholder="Username or Email" aria-label="Find Members" aria-describedby="button-search">
                                        <button class="btn btn-outline-secondary" type="button" id="button-search"><i class="bi bi-search"></i></button>
                                    </div>
                                    <button type="button" class="btn btn-lg btn-primary float-end">Submit</button>
                                    <button type="button" class="previous btn btn-lg btn-secondary float-end mx-3">Previous</button>
                                </fieldset>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
<?php } ?>

<?php function draw_connect_account_modal()
{ ?>
    <div class="modal fade" id="connectAccountModal" tabindex="-1" aria-labelledby="connectAccountModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="connectAccountModalLabel">Connect Account</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="d-grid gap-2">
                        <a href="#" role="button" class="btn btn-outline-secondary text-start fs-5"><i class="bi bi-facebook me-2"></i>Facebook</a>
                        <a href="#" role="button" class="btn btn-outline-secondary text-start fs-5"><i class="bi bi-instagram me-2"></i>Instagram</a>
                        <a href="#" role="button" class="btn btn-outline-secondary text-start fs-5"><i class="bi bi-twitter me-2"></i>Twitter</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
<?php } ?>

<?php function draw_notifications_modal()
{ ?>
    <div class="modal fade" id="notificationsModal" tabindex="-1" aria-labelledby="notificationsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="notificationsModalLabel">Notifications</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="card">
                        <div class="card-body">
                            <p class="card-text">Jane Doe invited you to "The Ultimate Apple Pie"</p>
                            <a href="#" class="stretched-link"></a>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <p class="card-text">"Get Ingredients" has been finished. You can start working on "Feed the culture"</p>
                            <a href="#" class="stretched-link"></a>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <p class="card-text">John Doe entered "Sourdough Baking"</p>
                            <a href="#" class="stretched-link"></a>
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-body">
                            <p class="card-text" data-bs-toggle="collapse" href="#collapseNotif1" role="button" aria-expanded="false" aria-controls="collapseExample"><span>Your report has been dealt with<i class="pull-right icon-chevron-right"></i></span></p>
                        </div>
                        <div class="collapse" id="collapseNotif1">
                            <div class="card card-body">
                                <strong>We reviewed antbz's account and found that it does not violate our community guidelines</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
<?php } ?>

<?php function draw_statistics_modal()
{ ?>
    <div class="modal fade" id="statisticsModal" tabindex="-1" aria-labelledby="statisticsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="statisticsModalLabel">Account Statistics</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body d-flex justify-content-between mt-3 stats-dashboard">
                    <div class="d-flex flex-column mx-3 stats-block">
                        <ul class="list-group list-group-flush">
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
                        <div class="row mt-3">
                            <div class="col-6" style="height:140px;width:140px;overflow:hidden;">
                                <img style="height:140px;" src="https://assets.bonappetit.com/photos/597f6564e85ce178131a6475/master/w_1200,c_limit/0817-murray-mancini-dried-tomato-pie.jpg">
                            </div>
                            <div class="col-6">
                                <h4>Top Post</h4>
                                <q>New recipe! Check out the blog!</q>
                                <p class="fw-light">124 likes</p>
                            </div>
                        </div>
                    </div>
                    <img class="img-fluid shadow mx-3 stats-block" src="https://www.datasciencemadesimple.com/wp-content/uploads/2017/08/Line-chart-in-python-1.png ">
                </div>
            </div>
        </div>
    </div>
<?php } ?>

<?php function draw_tasks_modal($id, $title, $waiting_on, $subtasks, $checklist, $status)
{ ?>
    <div class="modal fade" id="tasks<?=$id?>Modal" tabindex="-1" aria-labelledby="tasks<?=$id?>ModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="tasks<?=$id?>ModalLabel">
                        <ol class="my-0 breadcrumb text-muted">
                            <li class="breadcrumb-item"><a>Sourdough Baking</a></li>
                            <li class="breadcrumb-item active" aria-current="page"><?=$title?></li>
                        </ol>
                    </nav>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body d-grid gap-4 px-5">
                    <div>
                        <header>
                            <h3 class="d-inline-block"><?= $title ?></h3>
                            <h6 class="d-inline-block text-secondary mx-2"><?= $status ?></h6>
                        </header>
                        <textarea style="height:75px;width:100%;" placeholder="Description"></textarea>
                    </div>
                    <div>
                        <h5>Subtasks</h5>
                        <div class="d-grid gap-2 my-3">
                            <?php foreach ($subtasks as $id => $name) { ?>
                                <button type="button" style="background-color: #e7e7e7" class="btn text-start" data-bs-toggle="modal" data-bs-target="#tasks<?=$id?>Modal"><?=$name?></button>
                            <?php } ?>
                        </div>
                    </div>
                    <div>
                        <h5 class=" d-inline-block mr-3">Checklist</h5>
                        <p class=" d-inline-block text-secondary">100%</p>
                        <div class="progress w-50" style="height:5px;">
                            <div class="progress-bar" role="progressbar" style="width: 100%;height:5px;background-color:green;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <div class="d-grid gap-2 my-3">
                            <?php foreach ($checklist as $c) { ?>
                                <div class="form-check">
                                    <label class="form-check-label">
                                        <?= $c ?>
                                    <input class="form-check-input" type="checkbox" value="" checked>
                                    </label>
                                </div>
                            <?php } ?>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-4">
                            <p class="mb-1">Assigned to:</p>
                            <img class="rounded-circle" src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                        </div>
                        <div class="col-4">
                            <p class="mb-1">Waiting on:</p>
                            <h6><?=$waiting_on?></h6>
                        </div>
                        <div class="col-4">
                            <p class="mb-1">Deadline:</p>
                            <input type="date" class="form-control">
                        </div>
                    </div>
                    <div>
                        <h5>Comments</h5>
                        <div class="mb-3">
                            <div class="comment mb-3">
                                <div class="comment-body d-flex ms-2">
                                    <img class="rounded-circle mt-1" src="images/avatar.png" width="30px" height="30px" alt="avatar">
                                    <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2" style="background-color: #e7e7e7">
                                        Are you sure these are all the ingredients needed?
                                    </div>
                                    <a class="p-1 mx-2 d-flex align-items-center" data-bs-toggle="collapse" href="#comment1reply" role="button" aria-expanded="false" aria-controls="comment1reply">
                                        <i class="bi bi-chat-text fs-5 text-muted"></i>
                                    </a>
                                </div>
                                <div id="comment1reply" class="collapse">
                                    <div class="comment-replies my-2 ms-5">
                                        <div class="comment-body d-flex ms-2">
                                            <img class="rounded-circle mt-1" src="images/avatar.png" width="30px" height="30px" alt="avatar">
                                            <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2" style="background-color: #e7e7e7">
                                                For this first post we only need these. Maybe for another one we need more but they are in another task.
                                            </div>
                                        </div>
                                    </div>
                                    <div class="comment-footer d-flex mt-2 ms-5">
                                        <input class="form-control me-3" type="text" placeholder="Add comment">
                                        <button type="button" class="btn btn-outline-secondary btn-sm">Reply</button>
                                    </div>
                                </div>
                            </div>
                            <div class="comment mb-4">
                                <div class="comment-body d-flex ms-2">
                                    <img class="rounded-circle mt-1" src="images/avatar.png" width="30px" height="30px" alt="avatar">
                                    <div class="rounded-3 border py-2 px-3 position-relative flex-grow-1 ms-2" style="background-color: #e7e7e7">
                                        I think you can assign this task to me.. I may be able to complete it quickly!
                                    </div>
                                    <a class="p-1 mx-2 d-flex align-items-center" data-bs-toggle="collapse" href="#comment2reply" role="button" aria-expanded="false" aria-controls="comment2reply">
                                        <i class="bi bi-chat-text fs-5 text-muted"></i>
                                    </a>
                                </div>
                                <div id="comment2reply" class="collapse">
                                    <div class="comment-replies my-2 ms-5"></div>
                                    <div class="comment-footer d-flex mt-2 ms-5">
                                        <input class="form-control me-3" type="text" placeholder="Add comment">
                                        <button type="button" class="btn btn-outline-secondary btn-sm">Reply</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex">
                            <input class="form-control me-3" type="text" placeholder="Add comment">
                            <button type="button" class="btn btn-primary">Comment</button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-danger">Delete</button>
                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">Save changes</button>
                </div>
            </div>
        </div>
    </div>
<?php } ?>