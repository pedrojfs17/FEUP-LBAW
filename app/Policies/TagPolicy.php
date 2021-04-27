<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Tag;

class TagPolicy
{
  use HandlesAuthorization;

  public function create(Account $account, Tag $tag)
  {
    // Only an editor of a project can create a tag
    $member = Project::find($tag->project)->teamMembers()->keyBy('client_id')->get($account->id);
    return $member!=null && $member->member_role == 'Editor';
  }

  public function delete(Account $account, Tag $tag)
  {
    // Only an editor of a project can delete a tag
    $member = Project::find($tag->project)->teamMembers()->keyBy('client_id')->get($account->id);
    return $member!=null && $member->member_role == 'Editor';
  }
}
