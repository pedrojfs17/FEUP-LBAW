<div class="modal fade" id="tasks{{$task->id}}Modal" tabindex="-1" aria-labelledby="tasks{{$task->id}}ModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb" id="tasks{{$task->id}}ModalLabel">
                    <ol class="my-0 breadcrumb text-muted">
                        <li class="breadcrumb-item"><a>{{$project}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{$task->name}}</li>
                    </ol>
                </nav>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body d-grid gap-4 px-sm-5">
                <div>
                    <header>
                        <h3 class="d-inline-block">{{$task->name}}</h3>
                        <h6 class="d-inline-block text-secondary mx-2">{{$task->status}}</h6>
                    </header>
                    <textarea style="height:75px;width:100%;" placeholder="{{$task->description}}"></textarea>
                </div>
                <div>
                    <h5>Subtasks</h5>
                    <div class="d-grid gap-2 my-3">
                       @foreach ($task->subtasks as $subtask) { ?>
                        <button type="button" style="background-color: #e7e7e7" class="btn text-start" data-bs-toggle="modal" data-bs-target="#tasks{{$subtask->id}}Modal">{{$subtask->name}}</button>
                       @endforeach
                    </div>
                </div>
                <div class="row">
                    <div class="col-12 col-lg-6">
                        <h5 class=" d-inline-block mr-3">Checklist</h5>
                        <p class=" d-inline-block text-secondary">100%</p>
                        <div class="progress" style="height:5px;">
                            <div class="progress-bar" role="progressbar" style="width: 100%;height:5px;background-color:green;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                        <div class="d-grid gap-2 my-3">
                            @foreach ($task->checklistItems as $c) { ?>
                            <div class="form-check">
                                <label class="form-check-label">
                                    {{$c}}
                                    <input class="form-check-input" type="checkbox" value="" checked>
                                </label>
                            </div>
                            @endforeach
                        </div>
                    </div>
                    <div class="col-12 col-lg-6">
                        <h5 class=" d-inline-block mr-3">Tags</h5>
                        <a class="text-muted float-end" data-bs-toggle="collapse" href="#task{{$task->id}}CreateTag" role="button" aria-expanded="false" aria-controls="task{{$task->id}}CreateTag"><i class="bi bi-plus-circle"></i></a>
                        <div id="task{{$task->id}}CreateTag" class="collapse mb-3">
                            <form class="d-flex">
                                <input type="text" class="form-control" placeholder="Tag Name" aria-label="Tag name">
                                <input type="color" class="form-control form-control-color mx-2" value="#20c94d" title="Choose tag color">
                                <button type="submit" class="btn btn-outline-secondary flex-grow-1">Add</button>
                            </form>
                        </div>

                        <div class="d-flex flex-wrap gap-2 my-2 mt-auto">
                          @foreach ($task->tags as $tag)
                            <p class="d-inline-block m-0 py-1 px-2 rounded text-bg-check" type="button" style="background-color: {{ $tag->color }}">
                              <small>{{ $tag->name }}</small></p>
                          @endforeach
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-4 mb-4">
                        <h5 class="mb-1">Assigned to:</h5>
                        <img class="rounded-circle" src="images/avatar.png " width="40px " height="40px " alt="avatar ">
                    </div>
                    <div class="col-lg-4 mb-3">
                        <h5 class="mb-1">Waiting on:</h5>
                        <h6>{{$task->waitingOn}}</h6>
                    </div>
                    <div class="col-lg-4">
                        <h5 class="mb-1">Deadline:</h5>
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
