@foreach ($assignees as $assignee)
  <a class='text-decoration-none' target="_blank" rel="noopener noreferrer" href="/profile/{{$assignee->account->username}}">
  <img class="rounded-circle" src="{{ url($assignee->avatar) }}" data-bs-toggle="tooltip"
       data-bs-placement="top" title="{{$assignee->account->username}}" width="40px " height="40px "
       alt="avatar">
  </a>
@endforeach
