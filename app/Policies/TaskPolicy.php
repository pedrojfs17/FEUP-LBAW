<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Project;

use Illuminate\Auth\Access\HandlesAuthorization;

class TaskPolicy
{
  use HandlesAuthorization;

  public function list(Account $account, Project $project)
  {
    // Only a team member can see project tasks
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function create(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can create tasks
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function show(Account $account, Project $project)
  {
    // Only a team member can see a task
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function update(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can edit tasks
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function delete(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can delete tasks
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function tag(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can add tags to tasks
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function subtask(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can create subtasks
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function waiting_on(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can add a waiting relationship to a task
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function assignment(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can add an assignment
    return $project->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function comment(Account $account, Project $project)
  {
    // Only a team member can comment in a task
    return $project->teamMembers()->where('client_id', $account->id)->exists();
  }
}