<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Project;

class ProjectPolicy
{
  use HandlesAuthorization;

  public function create(Account $account, Project $project)
  {
    // Any client can create a project
    return Auth::check();
  }

  public function show(Account $account, Project $project)
  {
    // Only a team member can see a project
    return $project->teamMembers()->keyBy('client_id')->get($account->id) != null;
  }

  public function list(Account $account, Project $project)
  {

    return Auth::check();
  }

  public function update(Account $account, Project $project)
  {
    // Only an editor can update a project
    $member = $project->teamMembers()->keyBy('client_id')->get($account->id);
    return $member!=null && $member->member_role == 'Editor';
  }

  public function delete(Account $account, Project $project)
  {
    // Only an owner can update a project
    $member = $project->teamMembers()->keyBy('client_id')->get($account->id);
    return $member!=null && $member->member_role == 'Owner';
  }

  public function leave(Account $account, Project $project)
  {
    // Only a team member can leave a project
    return $project->teamMembers()->keyBy('client_id')->get($account->id)!=null;
  }

  public function preferences(Account $account, Project $project)
  {
    // Only an owner can see a project's settings
    $member = $project->teamMembers()->keyBy('client_id')->get($account->id);
    return $member!=null && $member->member_role == 'Owner';
  }

  public function assignents(Account $account, Project $project)
  {
    // Only a team member can see a project's assignments
    return $project->teamMembers()->keyBy('client_id')->get($account->id)!=null;
  }

  public function status_board(Account $account, Project $project)
  {
    // Only a team member can see a project's status board
    return $project->teamMembers()->keyBy('client_id')->get($account->id)!=null;
  }

  public function overview(Account $account, Project $project)
  {
    // Only a team member can see a project's overview
    return $project->teamMembers()->keyBy('client_id')->get($account->id)!=null;
  }

  public function invite(Account $account, Project $project)
  {
    // Only an owner can invite a client
    $member = $project->teamMembers()->keyBy('client_id')->get($account->id);
    return $member!=null && $member->member_role == 'Owner';
  }

  public function updateInvite(Account $account, Project $project)
  {
    // Any client can make a decision about an invite
    return Auth::check();
  }
}
