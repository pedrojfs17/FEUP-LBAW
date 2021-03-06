@extends('layouts.app')

@push('scripts')
  <script src="{{ asset('js/min/min-form-validation.js') }}" defer></script>
  <script src="{{ asset('js/min/min-ajax.js') }}" defer></script>
  <script src="{{ asset('js/min/min-settings.js') }}" defer></script>
@endpush

@push('styles')
  <link rel="stylesheet" href="{{ asset('css/min/min-style.css') }}">
@endpush

@section('navbar')
  @include('partials.navBar')
@endsection

@section('content')
<div class="container mb-5">
  @csrf
  <div class="row align-items-center mt-5">
    <h1><a class="fs-4 me-4" href={{ URL::previous() }}><i class="bi bi-chevron-left"></i></a>Settings</h1>
  </div>

  <hr>

  <div class="row align-items-center mt-4 px-sm-5 px-1">
    <h4>Notifications</h4>
    <hr>
  </div>

  <div class="row justify-content-center align-items-begin px-sm-5 px-1">
    <div class="row mt-2 form-switch ps-0">
      <label class="form-check-label" for="allow_noti">Allow Notifications</label>
      <input class="form-check-input settings-button" type="checkbox" id="allow_noti" name="allow_noti" @if ($user->allow_noti) checked @endif>
    </div>
    <div id="notificationSettings" class="mt-3">
      <div class="row mb-3 form-switch mx-0">
        <label class="form-check-label" for="invite_noti">Project Invites</label>
        <input class="form-check-input settings-button" type="checkbox" id="invite_noti" name="invite_noti" @if ($user->invite_noti) checked @endif>
      </div>
      <div class="row mb-3 form-switch mx-0">
        <label class="form-check-label" for="assign_noti">Assigned Tasks</label>
        <input class="form-check-input settings-button" type="checkbox" id="assign_noti" name="assign_noti" @if ($user->assign_noti) checked @endif>
      </div>
      <div class="row mb-3 form-switch mx-0">
        <label class="form-check-label" for="waiting_noti">Tasks leaving "Waiting"</label>
        <input class="form-check-input settings-button" type="checkbox" id="waiting_noti" name="waiting_noti" @if ($user->waiting_noti) checked @endif>
      </div>
      <div class="row mb-3 form-switch mx-0">
        <label class="form-check-label" for="comment_noti">Comments</label>
        <input class="form-check-input settings-button" type="checkbox" id="comment_noti" name="comment_noti" @if ($user->comment_noti) checked @endif>
      </div>
      <div class="row mb-3 form-switch mx-0">
        <label class="form-check-label" for="report_noti">Reports</label>
        <input class="form-check-input settings-button" type="checkbox" id="report_noti" name="report_noti" @if ($user->report_noti) checked @endif>
      </div>
    </div>
  </div>

  <div class="row align-items-center mt-4 px-sm-5 px-1">
    <h4>Projects</h4>
    <hr>
  </div>

  <div class="row justify-content-center align-items-begin px-sm-5 px-1">
    <div class="row mt-2 form-switch ps-0">
      <label class="form-check-label" for="hide_completed">Hide Completed Tasks</label>
      <input class="form-check-input settings-button" type="checkbox" id="hide_completed" name="hide_completed" @if ($user->hide_completed) checked @endif>
    </div>
    <div class="row mt-3 form-switch ps-0">
      <label class="form-check-label" for="simplified_tasks">Simplified Tasks</label>
      <input class="form-check-input settings-button" type="checkbox" id="simplified_tasks" name="simplified_tasks" @if ($user->simplified_tasks) checked @endif>
    </div>
    <div class="row mt-2 form-switch ps-0 position-relative align-items-center">
      <label class="form-label mt-2" for="color">Color</label>
      <input type="color" class="color-input form-control form-control-color choose-color position-absolute top-0 end-0"
             id="color" value="{{ $user->color }}" title="Choose your color">
    </div>

  </div>

  <div class="row align-items-center mt-4 px-sm-5 px-1">
    <h4>Account</h4>
    <hr>
  </div>

  <div class="row justify-content-center align-items-begin px-sm-5 px-1">
    <div class="d-grid gap-2 mb-3">
      <button class="btn btn-dark reset-form-button" type="button" data-target="changePassword" data-bs-toggle="collapse" data-bs-target="#changePassword" aria-expanded="false" aria-controls="changePassword">
        Change Password
      </button>
    </div>

    <form class="collapse row justify-content-center align-items-begin mb-3 edit-form validate-form" novalidate id="changePassword" data-href="password" data-validate-function="validateRecoverPasswordForm" data-on-submit="clearFields">
      @csrf
      <div class="col-lg-4 p-0">
        <label for="inputPassword" class="form-label">Old Password <span class="text-muted">*</span></label>
        <input type="password" class="form-control" id="inputPassword" name="password" required aria-describedby="inputPasswordFeedback">
        <div id="inputPasswordFeedback" class="invalid-feedback"></div>
      </div>
      <div class="col-lg-4 p-0">
        <label for="inputNewPassword" class="form-label">New Password <span class="text-muted">*</span></label>
        <input type="password" class="form-control" id="inputNewPassword" name="new_password" required aria-describedby="inputNewPasswordFeedback">
        <div id="inputNewPasswordFeedback" class="invalid-feedback">Password must be at least 6 characters long!</div>
      </div>
      <div class="col-lg-4 p-0">
        <label for="inputNewPasswordConfirmation" class="form-label">New Password Confirmation <span class="text-muted">*</span></label>
        <input type="password" class="form-control" id="inputNewPasswordConfirmation" name="new_password_confirmation" required aria-describedby="inputNewPasswordConfirmationFeedback">
        <div id="inputNewPasswordConfirmationFeedback" class="invalid-feedback">Passwords must match!</div>
        <div class="d-grid pt-4 gap-2">
          <button type="submit" class="btn btn-dark">Confirm</button>
        </div>
      </div>
    </form>
  </div>

  <div class="row justify-content-center align-items-begin px-sm-5 px-1">
    <div class="d-grid gap-2">
      <button class="btn btn-danger btn-danger-red" type="button" data-bs-toggle="modal" data-bs-target="#deleteAccountModal">Delete Account</button>
    </div>
  </div>

  <!-- Delete Account Modal -->
  <div class="modal fade" id="deleteAccountModal" tabindex="-1" aria-labelledby="deleteAccountModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Delete Account</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          Are you sure you want to delete your account? Once you delete your account there is no coming back!
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <form method="POST" action="/profile/{{ $user->account->username }}">
            @method('DELETE')
            @csrf
            <button type="submit" class="btn btn-danger btn-danger-red">Delete</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

@include('partials.helpers.settingsHelper')

@endsection
