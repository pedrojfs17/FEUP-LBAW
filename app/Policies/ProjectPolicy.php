<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Client;
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
    // Only an owner can update a project
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists();
  }

  public function delete(Account $account, Project $project)
  {
    // Only an owner can update a project
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists();
  }

  public function changePermissions(Account $account, Project $project)
  {
    // Only an owner can update a project
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists();
  }

  public function leave(Account $account, Project $project, Account $deletedUser)
  {
    // Only a team member can leave a project. Only an Owner can kick a member
    return $project->teamMembers()->where('client_id', $deletedUser->id)->exists() && (
      $account->id === $deletedUser->id
      || $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists()
      );
  }

  public function preferences(Account $account, Project $project)
  {
    // Only a team member can see a project's settings
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function assignments(Account $account, Project $project)
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

  public function invite(Account $account, Project $project, Client $client)
  {
    // Only an owner can invite a client
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists()
      && !$project->teamMembers()->where('client_id', '=', $client->id)->exists();
  }

  public function updateInvite(Account $account, Project $project, bool $decision)
  {
    // Only the invited client can change the decision
    // Or the project owner if the decision is false
    return $project->invites()->where('client_id', $account->id)->exists() ||
    $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => 'Owner'])->exists() && !$decision;
  }

  public function createTag(Account $account, Project $project)
  {
    // Only an editor or owner of a project can create a tag
    return $project->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function deleteTag(Account $account, Project $project)
  {
    // Only an editor or owner of a project can create a tag
    return $project->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function showTasks(Account $account, Project $project)
  {
    // Only a team member can see project tasks
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function createTask(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can create tasks
    return $project->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function updateTask(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can edit tasks
    return $project->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function deleteTask(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can delete tasks
    return $project->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }
}
