@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/script.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/overview.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
  @if ($errors->any())
    <div class="alert alert-danger text-center" role="alert">
      {{ $errors->first() }}
    </div>
  @endif

  @if (session('message') !== null)
    <div class="alert alert-success text-center" role="alert">
      {{ session('message') }}
    </div>
  @endif

  @include('partials.adminNavBar', ['page' => 'users'])

  @csrf

  <div class="container">
    <div class="accordion" id="accordionAdmin">
      <div class="accordion-item">
        <h2 class="accordion-header" id="headingOne">
          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                  data-bs-target="#collapseOne" aria-expanded="false" aria-controls="collapseOne">
            Reported Users
          </button>
        </h2>
        <div id="collapseOne" class="accordion-collapse collapse" aria-labelledby="headingOne">
          <div class="accordion-body">
          </div>
        </div>
      </div>
      <div class="accordion-item">
        <h2 class="accordion-header" id="headingTwo">
          <button class="accordion-button" type="button" data-bs-toggle="collapse"
                  data-bs-target="#collapseTwo" aria-expanded="true" aria-controls="collapseTwo">
            All Users
          </button>
        </h2>
        <div id="collapseTwo" class="accordion-collapse collapse show" aria-labelledby="headingTwo">
          <div class="accordion-body">
            @each('partials.memberCard', $users, 'member')
          </div>
        </div>
      </div>
    </div>
  </div>
@endsection
