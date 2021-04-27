<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Tag;

use Illuminate\Auth\Access\HandlesAuthorization;

class TagPolicy
{
  use HandlesAuthorization;

  public function create(Account $account, Tag $tag)
  {
    // Only an editor or owner of a project can create a tag
    return $tag->project()->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }

  public function delete(Account $account, Tag $tag)
  {
    // Only an editor or owner of a project can delete a tag
    return $tag->project()->teamMembers()->where(['client_id' => $account->id, 'member_role' => ['Editor', 'Owner']])->exists();
  }
}
