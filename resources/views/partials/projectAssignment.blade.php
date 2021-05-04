<div class="carousel-item @if ($active) active @endif">
  <div class="col-12 col-md-4">
    <div class="card mb-2">
      <div class="card-header text-center text-bg-check"
           style="background-color: {{$team_member->color}}">
          {{$team_member->account->username}}
      </div>
      <div class="card-body ">
        <div class="d-grid gap-2 ">
          @foreach($team_member->tasks as $task)
            @if ($task->project == $project->id)
            <button class="btn btn-light text-start " type="button">{{$task->name}}</button>
            @endif
          @endforeach
        </div>
      </div>
    </div>
  </div>
</div>
