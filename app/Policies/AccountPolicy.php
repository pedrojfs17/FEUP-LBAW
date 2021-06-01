<?php

namespace App\Policies;

use App\Models\Account;
use Illuminate\Auth\Access\HandlesAuthorization;

class AccountPolicy
{
    use HandlesAuthorization;

    public function delete(Account $account, Account $deleting)
    {
        return $account->is_admin && $account->id == $deleting->id;
    }
}
