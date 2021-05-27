<div class="card my-2">
  <div class="card-body">
    <h5 class="card-title">{{$task->name}}</h5>
    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb">
      <ol class="my-0 breadcrumb">
        <li class="breadcrumb-item"><a href="{{route('project.overview',['id'=> $task->project])}}">{{$task->project()->first()->name}}</a></li>
        <li class="breadcrumb-item active"><a href="{{route('project.overview',['id'=> $task->project])}}">{{$task->name}}</a></li>
      </ol>
    </nav>
  </div>
</div>
