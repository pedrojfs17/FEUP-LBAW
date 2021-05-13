
@foreach($users as $member)
    @include('partials.projectMember', ['member'=>$member, 'role'=>'Reader'])
@endforeach
