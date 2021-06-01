<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\URL;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array
     */
    protected $policies = [
      'App\Models\Account' => 'App\Policies\AccountPolicy',
      'App\Models\Client' => 'App\Policies\ClientPolicy',
      'App\Models\Project' => 'App\Policies\ProjectPolicy',
      'App\Models\SocialMediaAccount' => 'App\Policies\SocialMediaAccountPolicy',
      'App\Models\Task' => 'App\Policies\TaskPolicy'
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
      $this->registerPolicies();
      ResetPassword::createUrlUsing(function ($user, string $token) {
        return URL::to('/') . '/recover_password?token='.$token;
      });
    }
}
