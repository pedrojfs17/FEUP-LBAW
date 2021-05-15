<div class="card my-1">
  <div class="card-body">
    <img class="rounded-circle d-inline-block mx-2" src="{{ url($client->avatar) }}" width="40px" height="40px"
         alt="avatar">
    <h5 class="card-title d-inline-block">{{ $client->account->username }}</h5>
    <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0 add-member-btn" data-id="{{$client->id}}"><i class="fas fa-user-plus"></i></button>
  </div>
</div>
