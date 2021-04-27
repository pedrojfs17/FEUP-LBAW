<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\SocialMediaAccount;

class SocialMediaAccountPolicy
{
  use HandlesAuthorization;

  public function create(Account $account, SocialMediaAccount $socialMediaAccount)
  {
    // Any client can create a socialMediaAccount
    return Auth::check();
  }

  public function show(Account $account, SocialMediaAccount $socialMediaAccount)
  {
    // Only a team member of a project or a client can see a social media account
    return $socialMediaAccount->client()->keyBy('id')->get($account->id) != null || $socialMediaAccount->project()->teamMembers()->keyBy('client_id')->get($account->id)!=null;
  }

  public function delete(Account $account, SocialMediaAccount $socialMediaAccount)
  {
    // Only a team member of a project or a client can delete a social media account
    return $socialMediaAccount->client()->keyBy('id')->get($account->id) != null || $socialMediaAccount->project()->teamMembers()->keyBy('client_id')->get($account->id)!=null;
  }

}
