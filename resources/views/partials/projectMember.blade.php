<div class="card my-1">
  <div class="card-body">
    <img class="rounded-circle d-inline-block mx-2" src="{{ url($member->avatar) }}" width="40px" height="40px"
         alt="avatar">
    <h5 class="card-title d-inline-block">{{ $member->account->username }}</h5>
    <h6 class="d-inline-block text-muted">{{ isset($member->pivot->member_role) ? $member->pivot->member_role : $member->account->email }}</h6>
    <button class="btn btn-danger float-end" type="button">Remove</button>
  </div>
</div>
