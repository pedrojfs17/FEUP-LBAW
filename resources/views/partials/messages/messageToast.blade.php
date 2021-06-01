@switch($type)
  @case('Success')
    @include('partials.messages.successMessage')
  @break

  @case('Fail')
    @include('partials.messages.failedMessage')
  @break

  @case('Info')
    @include('partials.messages.infoMessage')
  @break
@endswitch
