<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Project;

use App\Models\Task;
use Illuminate\Auth\Access\HandlesAuthorization;

class TaskPolicy
{
  use HandlesAuthorization;

  public function show(Account $account, Task $task)
  {
    // Only a team member can see a task
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function tag(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can add tags to tasks
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function subtask(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can create subtasks
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function waiting_on(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can add a waiting relationship to a task
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function assignment(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can add an assignment
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function comment(Account $account, Task $task)
  {
    // Only a team member can comment in a task
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->exists();
  }

  public function createCheckListItem(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can add a check list item
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function updateCheckListItem(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can update a check list item
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }

  public function deleteCheckListItem(Account $account, Task $task)
  {
    // Only team members with Editor or Owner permissions can delete a check list item
    return $task->project()->first()->teamMembers()->where('client_id', $account->id)->whereIn('member_role', ['Editor', 'Owner'])->exists();
  }
}
