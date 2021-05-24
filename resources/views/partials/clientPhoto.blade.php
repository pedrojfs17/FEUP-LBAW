@foreach ($assignees as $assignee)
  <img class="rounded-circle" src="{{ url($assignee->avatar) }}" data-bs-toggle="tooltip"
       data-bs-placement="top" title="{{$assignee->account->username}}" width="40px " height="40px "
       alt="avatar ">
@endforeach
