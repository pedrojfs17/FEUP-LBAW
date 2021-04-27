@extends('layouts.app')

@push('scripts')
  <script src={{ asset('js/text-bg.js') }} defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href={{ asset('css/style.css') }}>
  <link rel="stylesheet" href={{ asset('css/overview.css') }}>
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection


@section('content')
<div class="container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start" id="overview">
  @include('partials.projectNavBar', ['page' => 'overview'])

  @foreach ($tasks as $task)
      @include('partials.task', ['task' => $task])
      @include('partials.taskModal', ['task' => $task])
  @endforeach

  <div class="card m-2 border-3 border-secondary d-flex align-items-center justify-content-center"
       style="background-color: #efefef; border-style: dashed;">
    <i class="bi bi-plus-circle text-muted fs-2"></i>
    <a data-bs-toggle="modal" data-bs-target="#tasks0Modal" role="button" class="stretched-link p-0"></a>
  </div>
</div>
@endsection
