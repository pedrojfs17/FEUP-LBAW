@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/form-validation.js') }}" defer></script>
  <script src="{{ asset('js/ajax.js') }}" defer></script>
  <script src="{{ asset('js/profile.js') }}" defer></script>
  <script src="{{ asset('js/invite.js') }}" defer></script>
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
    @include('partials.project.projectNavBar', ['page' => 'preferences'])

    <div class="container">
      <div class="row align-items-center mt-3 mt-sm-5 px-md-5">
        <div class='col'>
          <h4>Basic info</h4>
        </div>
        @if ($role == 'Owner')
        <div class='col text-end'>
          <button class="btn btn-link text-muted" id="editProfile">
            <i class="bi bi-pencil"></i>
          </button>
        </div>
        <div class='col text-end' id="editActions">
          <button class="btn btn-link text-muted" id="cancelEdit">
            <i class="bi bi-x fa-lg"></i>
          </button>
          <button class="btn btn-link text-muted" id="saveEdit" data-href="/api/project/{{ $project->id }}" data-on-edit="updateProjectName">
            <i class="bi bi-check fa-lg"></i>
          </button>
        </div>
        @endif
        <hr>
      </div>
      @if ($role == 'Owner')
      @include('partials.project.projectInfoForm', ['project' => $project])
      @else
      @include('partials.project.projectInfo', ['project' => $project])
      @endif

      <div class="row align-items-center mt-5 px-md-5">
        <h4>Members</h4>
        <hr>
      </div>

      <div class="mx-md-5">
        @foreach($members as $member)
          @include('partials.project.projectMember', ['member' => $member])
        @endforeach
        @if (count($project->getPendingInvites()) > 0)
          <h5 class='mt-3 mb-2'>Invites</h5>
          @foreach($project->getPendingInvites() as $invited)
            @include('partials.project.projectMember', ['member' => $invited])
          @endforeach
        @endif
      </div>

      <div class="row align-items-center mt-5 px-md-5">
        <h4>Danger Zone</h4>
        <hr>
      </div>

      <div class="row justify-content-center align-items-begin px-md-5">
        <div class="d-grid mb-3">
          <p class="text-muted mb-2">Once you leave this project, there is no coming back...</p>
          <button class="btn btn-danger btn-danger-red" type="button" data-bs-toggle="modal" data-bs-target="#leaveProjectModal">Leave Project</button>
        </div>
        @if ($role == 'Owner')
        <div class="d-grid">
          <p class="text-muted mb-2">Once you delete this project, there is no coming back...</p>
          <button class="btn btn-danger btn-danger-red" type="button" data-bs-toggle="modal" data-bs-target="#deleteProjectModal">Delete Project</button>
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
                <button type="submit" class="btn btn-danger btn-danger-red">Leave</button>
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
                <button type="submit" class="btn btn-danger btn-danger-red">Delete</button>
              </form>
            </div>
          </div>
        </div>
      </div>
      @endif
    </div>
  </div>
  @include('partials.helpers.preferencesHelper')
@endsection
