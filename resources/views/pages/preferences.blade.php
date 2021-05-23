@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/form-validation.js') }}" defer></script>
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
  <div class="mb-5 container-md d-flex flex-wrap align-content-stretch justify-content-center justify-content-md-start" id="preferences">
    @include('partials.projectNavBar', ['page' => 'preferences'])

    <div class="container">
      <div class="row align-items-center mt-5 px-5">
        <h4>Basic info</h4>
        <hr>
      </div>

      <section class="row justify-content-center align-items-begin px-5">
        <label for="name" class="form-label">Name</label>
        <div class="input-group mb-3">
          <input type="text" value="{{ $project->name }}" class="form-control" id="name" disabled>
          <button class="btn btn-outline-secondary edit-button" data-href="/api/project/{{ $project->id }}" data-edit-input="name" data-on-edit="updateProjectName" type="button"><i
              class="bi bi-pencil"></i></button>
        </div>

        <label for="description" class="form-label">Description</label>
        <div class="input-group mb-3">
          <textarea class="form-control" id="description" style="height: 8em;" disabled>{{ $project->description }}</textarea>
          <button class="btn btn-outline-secondary edit-button" data-href="/api/project/{{ $project->id }}" data-edit-input="description" type="button"><i
              class="bi bi-pencil"></i></button>
        </div>

        <label for="due_date" class="form-label">Due Date</label>
        <div class="input-group mb-3">
          <input type="date" value="{{ (new DateTime($project->due_date))->format('Y-m-d') }}" class="form-control" id="due_date" disabled>
          <button class="btn btn-outline-secondary edit-button" data-href="/api/project/{{ $project->id }}" data-edit-input="due_date" type="button"><i
              class="bi bi-pencil"></i></button>
        </div>
      </section>

      <div class="row align-items-center mt-5 px-5">
        <h4>Manage members</h4>
        <hr>
      </div>

      <div class="mx-5">
        @foreach($project->teamMembers as $member)
          @include('partials.projectMember', ['member' => $member])
        @endforeach
      </div>

      <div class="row align-items-center mt-5 px-5">
        <h4>Danger Zone</h4>
        <hr>
      </div>

      <div class="row justify-content-center align-items-begin px-5">
        <div class="d-grid mb-3">
          <p class="text-muted mb-2">Once you leave this project, there is no coming back...</p>
          <button class="btn btn-danger" type="button" data-bs-toggle="modal" data-bs-target="#leaveProjectModal">Leave Project</button>
        </div>
        @if ($role == 'Owner')
        <div class="d-grid">
          <p class="text-muted mb-2">Once you delete this project, there is no coming back...</p>
          <button class="btn btn-danger" type="button" data-bs-toggle="modal" data-bs-target="#deleteProjectModal">Delete Project</button>
        </div>
        @endif
      </div>

      <!-- Leave Modal -->
      <div class="modal fade" id="leaveProjectModal" tabindex="-1" aria-labelledby="leaveProjectModal" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Leave Project</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              Are you sure you want to leave this project?
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
              <form method="POST" action="/api/project/{{ $project->id }}/{{ Auth::user()->username }}">
                @method('DELETE')
                @csrf
                <button type="submit" class="btn btn-danger">Delete</button>
              </form>
            </div>
          </div>
        </div>
      </div>

      @if ($role == 'Owner')
      <!-- Delete Modal -->
      <div class="modal fade" id="deleteProjectModal" tabindex="-1" aria-labelledby="deleteProjectModal" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Delete Project</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              Are you sure you want to delete this project?
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
              <form method="POST" action="/api/project/{{ $project->id }}">
                @method('DELETE')
                @csrf
                <button type="submit" class="btn btn-danger">Delete</button>
              </form>
            </div>
          </div>
        </div>
      </div>
      @endif
    </div>
  </div>
@endsection
