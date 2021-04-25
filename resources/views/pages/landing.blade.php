@extends('layouts.app')

@push('scripts')
  <script src={{ asset('js/script.js') }} defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href={{ asset('css/one-page-wonder.css') }}>
@endpush

@section('navbar')
  @include('partials.landingNavBar')
@endsection

@section('content')
  <!-- Header -->
  <header class="masthead text-center text-white">
    <div class="masthead-content">
      <div class="container">
        <h1 class="masthead-heading mb-5">Social media has never been this easy!</h1>
        <h2 class="masthead-subheading mb-0">Oversee is here to make you reach new heights</h2>
        <a href="{{ route('register') }}" class="btn btn-primary btn-xl rounded-pill mt-5 mx-3">Join Oversee</a>
        <a class="btn btn-primary btn-xl rounded-pill mt-5" id="learnMore" href="#aboutPage">Learn More</a>
      </div>
    </div>
    <div class="bg-circle-1 bg-circle"></div>
    <div class="bg-circle-2 bg-circle"></div>
    <div class="bg-circle-3 bg-circle"></div>
    <div class="bg-circle-4 bg-circle"></div>
  </header>

  <section id="aboutPage">
    <section>
      <div class="container info">
        <div class="row align-items-center">
          <div class="col-lg-8 order-xl-1">
            <div class="p-5">
              <h2 class="display-4">Organize it!</h2>
              <p class="me-5 pe-5 fs-5">Oversee cards are your portal to more organized work—where every
                single part of your task can be managed, tracked, and shared with teammates. Open any
                card to uncover an ecosystem of checklists, due dates, conversations, and more.</p>
            </div>
          </div>
          <div class="col-lg-4 order-lg-2">
            <div class="p-5">
              <img class="img-fluid rounded-circle" src="{{ asset('images/01.jpg') }}" alt="">
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="container info">
        <div class="row align-items-center">
          <div class="col-lg-8 order-xl-2">
            <div class="p-5">
              <h2 class="display-4 ms-5 ps-5">Improve Yourself!</h2>
              <p class="ms-5 ps-5 fs-5">With all your data and insights in one place, you can see what’s
                working best and get recommendations to help you do more of it.</p>
            </div>
          </div>
          <div class="col-lg-4 order-lg-1">
            <div class="p-5">
              <img class="img-fluid rounded" src="{{ asset("images/02.jpg") }}" alt="">
            </div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="container info">
        <div class="row align-items-center">
          <div class="col-lg-8 order-xl-1">
            <div class="p-5">
              <h2 class="display-4">Go solo or go big!</h2>
              <p class="me-5 pe-5 fs-5">From the small stuff to the big picture, Oversee organizes work so
                teams know what to do, why it matters, and how to get it done.</p>
            </div>
          </div>
          <div class="col-lg-4 order-lg-2">
            <div class="p-5">
              <img class="img-fluid rounded" src="{{ asset("images/03.jpg") }}" alt="">
            </div>
          </div>
        </div>
      </div>
    </section>
  </section>
@endsection

@section('footer')
  @include('partials.landingFooter')
@endsection
