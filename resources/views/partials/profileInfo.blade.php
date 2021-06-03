<div class="row justify-content-center mt-5">
  <div class="col-lg-3 col-md-6 col-sm-6 d-flex align-items-center justify-content-center mx-3">
    <img src="{{ url($client->avatar) }}" alt="Avatar" class="img-fluid mx-auto d-block rounded-circle">
  </div>
  <div class="col-lg-4 align-items-center justify-content-center mx-3 my-auto">
    @if ($client->fullname)
    <h1 class="my-0">{{$client->fullname }}</h1>
    @else
    <h1 class="my-0">{{$client->account->username }}</h1>
    @endif
    <p class="profile-username">{{ $client->account->username }}</p>

    <hr>
    <div class="profile-info"><i class="fas fa-envelope"></i>
      <p class="d-inline-block">{{ $client->account->email }}</p>
    </div>

    @if ($client->company)
    <div class="profile-info"><i class="fas fa-briefcase"></i>
      <p class="d-inline-block">{{$client->company}}</p>
    </div>
    @endif

    @if ($client->country)
    <div class="profile-info"><i class="fas fa-map-marker-alt"></i>
      <p class="d-inline-block">{{$client->country()->first()->name}}</p>
    </div>
    @endif

    <div class="d-flex justify-content-around my-3 shadow p-3" style="border-radius: 15px">
      <div class="text-center">
        <h3 class="m-0">{{ $client->tasks()->count() }}</h3>
        <p class="m-0 profile-info">Tasks</p>
      </div>
      <div class="text-center">
        <h3 class="m-0" >{{ $client->comments()->count() }}</h3>
        <p class="m-0 profile-info">Comments</p>
      </div>
      <div class="text-center">
        <h3 class="m-0">{{ $client->projects()->count() }}</h3>
        <p class="m-0 profile-info">Projects</p>
      </div>
    </div>
  </div>
</div>
