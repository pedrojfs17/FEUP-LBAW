<div class="card my-1">
  <div class="card-body d-flex flex-row">
    <img class="rounded-circle me-3" src="{{ url($client->avatar) }}" width="50px" height="50px"
        alt="avatar">
    <div class='col'>
      <h5 class="card-title mb-0">{{ $client->fullname }}</h5>
      <p class="text-muted m-0">{{ $client->account->username }}</p>
    </div>
    <a class='text-decoration-none stretched-link' target="_blank" rel="noopener noreferrer" href="/profile/{{$client->account->username}}"></a>
    <button type="button" class="btn btn-danger flex-grow-1 flex-md-grow-0 add-member-btn" data-id="{{$client->id}}" style="z-index: 1;"><i class="fas fa-user-plus"></i></button>
  </div>
</div>
