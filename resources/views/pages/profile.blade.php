@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/profile.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/ms-form.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection


@section('content')
  <div class="container">
        @if (!Auth::user()->is_admin && $user->account->username == $client->account->username)
          @include('partials.profileForm',['client'=>$client, 'countries'=>$countries])
        @else
          @include('partials.profileInfo', ['client' => $client])
        @endif
  </div>
  @if($user->account->username == $client->account->username)
    @include('partials.helpers.profileHelper')
  @endif
@endsection
