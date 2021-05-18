<div class="card my-1">
  <div class="card-body invite" data-href="/api/project/{{ $invite->pivot->project_id }}/invite/{{$invite->pivot->client_id}}">
    @csrf
    <h5 class="card-title d-inline-block">{{ $invite->name }}</h5>
    <button type="button" class="btn btn-success flex-grow-1 flex-md-grow-0 acc-invite-btn" data-decision="1"><i class="fas fa-check"></i></button>
    <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0 acc-invite-btn" data-decision="0"><i class="fas fa-close"></i></button>
  </div>
</div>
