<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Admin;
use Illuminate\Auth\Access\HandlesAuthorization;

class AdminPolicy
{
  use HandlesAuthorization;

  public function users(Account $account, Admin $admin)
  {
    // Only an admin can access this page
    return $account->id == $admin->id;
  }

  public function statistics(Account $account, Admin $admin)
  {
    // Only an admin can access this page
    return $account->id == $admin->id;
  }

  public function support(Account $account, Admin $admin)
  {
    // Only an admin can access this page
    return $account->id == $admin->id;
  }

}
