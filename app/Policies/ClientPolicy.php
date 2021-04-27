<?php


namespace App\Policies;


use App\Models\Account;
use App\Models\Admin;
use App\Models\Client;

use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Support\Facades\Auth;

class ClientPolicy
{
  use HandlesAuthorization;

  public function show(Account $account, Client $client)
  {
    // Any client can see a profile
    return Auth::check();
  }

  public function update(Account $account, Client $client)
  {
    // Only the user can update his information
    return $account->id == $client->id;
  }

  public function delete(Account $account, Client $client)
  {
    // Only the user or an admin can delete an account
    return $account->id == $client->id || Admin::find($account->id) != null;
  }

  public function showSettings(Account $account, Client $client)
  {
    // Only the user can see his settings
    return $account->id == $client->id;
  }

  public function updateSettings(Account $account, Client $client)
  {
    // Only the user can update his settings
    return $account->id == $client->id;
  }

}
