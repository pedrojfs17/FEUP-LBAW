<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Client;

use Illuminate\Auth\Access\HandlesAuthorization;

class ClientPolicy
{
  use HandlesAuthorization;

  public function update(Account $account, Client $client)
  {
    // Only the user can update his information
    return $account->id == $client->id;
  }

  public function delete(Account $account, Client $client)
  {
    // Only the user or an admin can delete an account
    return $account->id == $client->id || $account->is_admin;
  }

}
