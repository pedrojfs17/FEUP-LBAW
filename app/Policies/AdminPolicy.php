<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Admin;
use Illuminate\Auth\Access\HandlesAuthorization;

class AdminPolicy
{
  use HandlesAuthorization;

  public function users(Account $account)
  {
    // Only an admin can access this page
    return Admin::find($account->id) != null;
  }

  public function statistics(Account $account)
  {
    // Only an admin can access this page
    return Admin::find($account->id) != null;
  }

  public function support(Account $account)
  {
    // Only an admin can access this page
    return Admin::find($account->id) != null;
  }

}
