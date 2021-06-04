<div class="card my-1 mx-2" id='invite{{$invite->id}}'>
  <form class="card-body invite d-flex align-items-center" data-invite='invite{{$invite->id}}' data-project="/project/{{ $invite->pivot->project_id }}/overview" data-href="/api/project/{{ $invite->pivot->project_id }}/invite/{{$invite->pivot->client_id}}">
    @csrf
    <h5 class="card-title d-inline-block flex-grow-1">{{ $invite->name }}</h5>
    <div id='invite{{$invite->id}}Actions' class="d-flex">
      <button type="button" class="btn btn-primary acc-invite-btn mx-2 px-3 py-2" data-decision=1><i class="fas fa-check"></i></button>
      <button type="button" class="btn btn-danger acc-invite-btn px-3 py-2" data-decision=0><i class="fas fa-close" style="width:16px;"></i></button>
    </div>
  </form>
</div>
