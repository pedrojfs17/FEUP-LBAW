<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Project;

use Illuminate\Auth\Access\HandlesAuthorization;

class ProjectPolicy
{
  use HandlesAuthorization;

  public function show(Account $account, Project $project)
  {
    // Only a team member can see a project
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function update(Account $account, Project $project)
  {
    // Only an editor or owner can update a project
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function delete(Account $account, Project $project)
  {
    // Only an owner can update a project
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists();
  }

  public function leave(Account $account, Project $project)
  {
    // Only a team member can leave a project
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function preferences(Account $account, Project $project)
  {
    // Only a team member can see a project's settings
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function assignents(Account $account, Project $project)
  {
    // Only a team member can see a project's assignments
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function status_board(Account $account, Project $project)
  {
    // Only a team member can see a project's status board
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function statistics(Account $account, Project $project)
  {
    // Only a team member can see a project's status board
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function overview(Account $account, Project $project)
  {
    // Only a team member can see a project's overview
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function invite(Account $account, Project $project)
  {
    // Only an owner can invite a client
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists();
  }

  public function updateInvite(Account $account, Project $project)
  {
    // Only the invited client can change the decision
    return $project->invites()->where('client_id', $account->id)->exists();
  }
}
