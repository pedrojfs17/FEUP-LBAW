<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Task;

class TaskPolicy
{
  use HandlesAuthorization;

  public function list(Account $account, Project $project)
  {
    // Only a team member can see project tasks
    return $project->teamMembers()->keyBy('client_id')->get($account->id) != null;
  }

  public function create(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can create tasks
    return $project->teamMembers()->wherePivotIn('member_role', ['Editor', 'Owner'])->keyBy('client_id')->get($account->id) != null;
  }

  public function show(Account $account, Project $project)
  {
    // Only a team member can see a task
    return $project->teamMembers()->keyBy('client_id')->get($account->id) != null;
  }

  public function update(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can edit tasks
    return $project->teamMembers()->wherePivotIn('member_role', ['Editor', 'Owner'])->keyBy('client_id')->get($account->id) != null;
  }

  public function delete(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can delete tasks
    return $project->teamMembers()->wherePivotIn('member_role', ['Editor', 'Owner'])->keyBy('client_id')->get($account->id) != null;
  }

  public function tag(Account $account, Project $project)
  {
    // Only team members with Editor or Owner permissions can delete tasks
    return $project->teamMembers()->wherePivotIn('member_role', ['Editor', 'Owner'])->keyBy('client_id')->get($account->id) != null;
  }
}
