@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/script.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/one-page-wonder.css') }}">
@endpush

@section('navbar')
  @include('partials.landingNavBar', ['simple' => true])
@endsection

@section('content')
  <header class="not-found masthead text-center text-main-color ">
    <div class="masthead-content">
      <section>
        <div class="container info">
          <div class="col-lg-12 order-lg-1">
            <div class="p-12">
              <img class="img-fluid" src="{{ asset('images/dolphin.png') }}" width="600" alt="404 image">
            </div>
          </div>
          <div class="col-lg-12 order-lg-2">
            <h5 class="display-1">404</h5>
            <h5>Ups, seems like you wandered into the wrong pond</h5>
          </div>
        </div>
      </section>
    </div>
  </header>
@endsection

